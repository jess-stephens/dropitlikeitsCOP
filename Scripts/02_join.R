# Project: dropitlikeitsCOP
# Script: 01_msd
# Developers: Jessica Stephens (USAID)
# Use: to join the munged data sources for MSD, TST and KP targets

############################################################################

#IMPORT ------------------------------------------------------------------------

data_folder <- "C:/Users/jstephens/Documents/Zim/COP23/dropitlikeitsCOP/Dataout"

df_msd <- data_folder %>% 
  return_latest("df_msd_ratio_stdev") %>% 
  read_csv() %>% 
  filter(indicator %in% c("HTS_INDEX", "HTS_RECENT", "HTS_SELF", "HTS_TST", "HTS_TST_POS",
                          "TX_CURR", "TX_NEW", "TX_PVLS", "TX_PVLS_D", "CXCA_SCRN", "PMTCT_ART",
                          "PMTCT_EID", "PMTCT_STAT","PMTCT_STAT_D","TB_ART","TB_PREV",
                          "TB_PREV_D","TB_STAT","TB_STAT_D","TX_TB_D" ))

df_dp_tst <- data_folder %>% 
  return_latest("dp_collapse")%>% 
  read_csv()%>% 
  filter(indicator %in% c("HTS_INDEX", "HTS_RECENT", "HTS_SELF", "HTS_TST", "HTS_TST_POS",
                          "TX_CURR", "TX_NEW", "TX_PVLS", "TX_PVLS_D", "CXCA_SCRN", "PMTCT_ART",
                          "PMTCT_EID", "PMTCT_STAT","PMTCT_STAT_D","TB_ART","TB_PREV",
                          "TB_PREV_D","TB_STAT","TB_STAT_D","TX_TB_D" ))



df_kp_snu_join <-  data_folder %>% 
  return_latest("kp_snu_join")%>% 
  read_csv() %>% 
  filter(indicator %in% c("HTS_INDEX", "HTS_RECENT", "HTS_SELF", "HTS_TST", "HTS_TST_POS",
                          "TX_CURR", "TX_NEW", "TX_PVLS", "TX_PVLS_D", "CXCA_SCRN", "PMTCT_ART",
                          "PMTCT_EID", "PMTCT_STAT","PMTCT_STAT_D","TB_ART","TB_PREV",
                          "TB_PREV_D","TB_STAT","TB_STAT_D","TX_TB_D" ))

df_kp_ratio <-  data_folder %>% 
  return_latest("df_kp_ratio")%>% 
  read_csv() 

# names(df_msd) 
# names(df_dp_tst) 
# names(df_kp_snu_join)

#KP JOIN ----------------------------------------------------------------------

df_tst_kp<- df_dp_tst %>% 
  left_join(df_kp_snu_join) %>% 
  select(!c(standardizeddisaggregate, otherdisaggregate)) %>% 
  mutate(fy24_target_snu_kp = ifelse(is.na(fy24_target_snu_kp), 0, fy24_target_snu_kp))


#SUBTRACT KP FROM PLHIV TARGETS AT SNU LEVEL
df_tst_kp_gp<-df_tst_kp %>%
  mutate(fy24_target_snu_gp=FY24_target_snu - fy24_target_snu_kp) 



#MSD JOIN ----------------------------------------------------------------------
# need to left join to a psnu msd the snu tst kp many to one

df_tst_kp_msd<- df_msd %>% 
  left_join(df_tst_kp_gp) %>% 
  filter(!is.na(fy24_target_snu_gp))%>% 
  filter(!is.na(FY24_target_snu))%>% 
  filter(!is.na(fy24_target_snu_kp))

#allocate fy24_target_gp based on historical results - df_ratio_stdev
df_target_psnu<-df_tst_kp_msd %>% 
  mutate(fy24_target_psnu_gp=fy24_target_snu_gp*FY22_ratios)

#JOIN THE KP PSNU TARGETS (df_kp_ratio) TO THE PSNU MSD PRIOR TO TAKING GP TO PSNU
df_tst_kp_msd_psnu<- df_target_psnu %>% 
  left_join(df_kp_ratio)


# select desired variables
df_tst_kp_msd_psnu2<-df_tst_kp_msd_psnu %>% 
  mutate(fy24_target_psnu_gp=round(fy24_target_psnu_gp, 0),
         fy24_target_psnu_kp=round(fy24_target_psnu_kp, 0)) %>% 
  select(!c(FY22_ratios, FY24_target_snu,fy24_target_snu_kp,  fy24_target_snu_gp, fy24_ratios_kp)) 


#QC ------------------------------------------------------------------------
# 
# #collapse psnu targets dataset
# df_tst_kp_msd_psnu2_collapse<- df_tst_kp_msd_psnu2 %>% 
#   dplyr::select(!c(psnu)) %>% 
#   dplyr::group_by_if(is.character) %>%
#   dplyr::summarise_if(is.numeric, ~ sum(., na.rm = TRUE))%>% 
#   ungroup()
# 
# 
# #re-join tst and kp snu datasets to compare
# 
# qc_tst_snu<-df_tst_kp_msd_psnu2_collapse %>% 
#   left_join(dp_collapse, by = join_by(prime_partner_name, snu1,
#                                      indicator, trendscoarse, sex),multiple = "all")
# 
# 
# qc_kp_psnu<-df_tst_kp_msd_psnu2 %>% 
#   left_join(df_kp_psnu, by = join_by(prime_partner_name, snu1, psnu,
#                                      indicator, trendscoarse, sex))
# names(qc_kp_psnu)

# qc_kp_psnu_fix<-qc_kp_psnu %>% 
#   mutate(fy24_target_psnu_kp.x=ifelse(fy24_target_psnu_kp.x=0, 
#                                       fy24_target_psnu_kp.y, fy24_target_psnu_kp.x))


# qc_kp_snu<-df_tst_kp_msd_psnu2_collapse %>% 
#   left_join(df_kp_snu_join)




#EXPORT ------------------------------------------------------------------------

today <- lubridate::today()

# write_csv(qc_msd, glue::glue("Dataout/qc_msd_{today}_3.csv" ))
# write_csv(qc_kp_psnu, glue::glue("Dataout/qc_kp_psnu_{today}_6.csv" ))
# write_csv(qc_kp_snu, glue::glue("Dataout/qc_kp_snu_{today}_3.csv" ))


write_csv(df_tst_kp_msd_psnu, glue::glue("Dataout/ZIM_PSNU_TARGETS_{today}_full.csv" ))

