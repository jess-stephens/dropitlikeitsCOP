# Project: dropitlikeitsCOP
# Script: 01_msd
# Developers: Jessica Stephens (USAID)
# Use: to join the munged data sources for MSD, TST and KP targets

############################################################################

#IMPORT ------------------------------------------------------------------------

data_folder <- "C:/Users/jstephens/Documents/Zim/COP23/dropitlikeitsCOP/Dataout"

df_msd <- data_folder %>% 
  return_latest("df_msd_ratio_stdev") %>% 
  read_csv()


df_dp_tst <- data_folder %>% 
  return_latest("dp_collapse")%>% 
  read_csv()


df_kp_snu_join <-  data_folder %>% 
  return_latest("kp_snu_join")%>% 
  read_csv()


names(df_msd) #MSD MUNGED
names(df_dp_tst) #TST MUNGED
names(df_kp_snu_join)

#KP JOIN ----------------------------------------------------------------------


#for each indicator that it applies to at 15+
## ^^ OVC_SERV AND AGYW_PREV HAVE DATA FOR <15 -  I MERGED AND SUBTRACTED 
##not able to join correctly on standardized disaggregates because KP STDEV is DP Other

df_tst_kp<- df_dp_tst %>% 
  left_join(df_kp_snu_join)

#what are the partner names in the tst
df_tst_kp %>%
  select(c(prime_partner_name)) %>%
  unique()


test2<-df_kp_snu_join %>%
  select(c(indicator, standardizeddisaggregate)) %>%
  unique()

# 1 BANTWANA ZIMBABWE                                           
# 2 Centre for Sexual Health and HIV/AIDS Research Zimbabwe     
# 3 Dedup                                                       
# 4 FAMILY AIDS CARING TRUST                                    
# 5 Hospice and Palliative Care Association of Zimbabwe         
# 6 Mavambo Orphan Care                                         
# 7 ORGANIZATION FOR PUBLIC HEALTH INTERVENTIONS AND DEVELOPMENT
# 8 TBD (000000000)                                             
# 9 ZIMBABWE ASSOCIATION OF CHURCH RELATED HOSPITAL             
# 10 Zimbabwe Health Interventions   


#SUBTRACT KP FROM PLHIV TARGETS AT SNU LEVEL

# non- ace  / ophid, kp tx_curr taget for gp Tx_curr
# else == tx_curr ace / ophid and all other indicators

df_tst_kp_gp<-df_tst_kp %>% 
  mutate(fy24_target_gp=case_when(
    indicator=="TX_CURR" & 
    prime_partner_name!="ORGANIZATION FOR PUBLIC HEALTH INTERVENTIONS AND DEVELOPMENT"
    ~ fy24_target_snu_kp, 
    # indicator=="TX_CURR" & 
    #   prime_partner_name!="ACE" <<<<<<<<<<<<<<<<< need proper name
    # ~ fy24_target_snu_kp, 
    TRUE~ (FY24_target_snu - fy24_target_snu_kp)
  ))

#MSD JOIN ----------------------------------------------------------------------
df_tst_kp_msd<- df_tst_kp_gp %>% 
  left_join(df_msd)

allocate fy24_target_gp based on historical results - df_ratio_stdev 
# (ophid / ace / cdc - zimtec)
allocate fy24_target_snu based on df_kp_ratio

#wrench
1) cdc clinical partner is kp partner - use the df_kp_ratio? 
  2) 2 snus - usaid public sector partners have kp targets for tx_curr 
# 4 district <2000 
# will effect ratio of allocating kp targets back 


#------------ CONCEPT 
#IN THE KP PSNU, FIND THE RATIO / PERCENT CONTRIBUTION OF EACH PSNU TO THE SNU
# SNU=100
# PSNU1 KP=10 KP CONTRIBUTION = .1
# PSNU2 KP=10 KP CONTRIBUTION =.1
# PSNU3 KP=80 KP CONTRIBUTION =.8 






#JOIN ------------------------------------------------------------------------
#need to subtract KP SNU targets from df_dp_tst before this join

#JOIN FY24 TST GP TARGETS TO MSD FY22 RATIOS & APPLY

#CHECK IP NAMES ACROSS YEARS AND FIX

# replace dp collapse with df_psnu_tst_gp after kp removal from plhiv targets
#replace FY24_target_snu with fy24_target_gp after kp removal from plhiv targets
df_psnu_tst<- left_join(
  dp_collapse, df_ratio, 
  multiple="all") %>% 
  # select(prime_partner_name, snu1, psnu, indicator, indicatortype, numeratordenom, 
  #        standardizeddisaggregate, otherdisaggregate, modality, sex, trendscoarse, 
  #        FY22_ratios, FY23_target_snu) %>% 
  select(prime_partner_name, snu1, indicator, indicatortype,
         standardizeddisaggregate,  otherdisaggregate, sex, trendscoarse,
         FY22_ratios, FY24_target_snu) %>%
  mutate(FY24_target_psnu=FY24_target_snu * FY22_ratios) 


df_ratio_stdev


#EXPORT ------------------------------------------------------------------------

today <- lubridate::today()

write_csv(df_psnu_tst, glue::glue("Dataout/df_psnu_tst_{today}.csv" ))
