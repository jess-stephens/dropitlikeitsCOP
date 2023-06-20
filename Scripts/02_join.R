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

# df_tst_kp_check<-df_tst_kp %>%
#   mutate(qc=ifelse(FY24_target_snu<fy24_target_snu_kp, TRUE, FALSE)) %>% 
#   count(qc)
#there are 59 cases out of >1800 where the kp target is larger than the snu target



#PWID AND PRISONS == MALE???
#DONT KNOW HOW TO TELL APART THE TBD MECHS IN TST
# df_msd %>%
#   filter(prime_partner_name=="Population Services International" | prime_partner_name=="UNIVERSITY OF WASHINGTON") %>% 
#   select(c(prime_partner_name, psnu)) %>%
#   unique() %>% 
#   print(n = 46)


#SUBTRACT KP FROM PLHIV TARGETS AT SNU LEVEL

# non- ace  / ophid, kp tx_curr taRget for gp Tx_curr
# else == tx_curr ace / ophid and all other indicators

df_tst_kp_gp<-df_tst_kp %>% 
  mutate(fy24_target_gp=case_when(
    indicator=="TX_CURR" & 
    !(prime_partner_name %in% c("ORGANIZATION FOR PUBLIC HEALTH INTERVENTIONS AND DEVELOPMENT",
                               "Zimbabwe Health Interventions"))
    ~ fy24_target_snu_kp,
    TRUE~ (FY24_target_snu - fy24_target_snu_kp)
  )) %>% 
  filter(!is.na(fy24_target_gp))
#161 obs

#MSD JOIN ----------------------------------------------------------------------
# need to left join to a psnu msd the snu tst kp many to one

df_tst_kp_msd<- df_msd %>% 
  left_join(df_tst_kp_gp) %>% 
  filter(!is.na(fy24_target_gp))
#346 obs

#allocate fy24_target_gp based on historical results - df_ratio_stdev
df_target_psnu<-df_tst_kp_msd %>% 
  mutate(fy24_target_gp_psnu=fy24_target_gp*FY22_ratios)

#JOIN THE KP PSNU TARGETS TO THE PSNU MSD PRIOR TO TAKING GP TO PSNU
# COMBINE THE RATIOS OF THE KP PSNU / SNU BEFORE BACKING OUT (INVERSE KP RATIOS?)

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



#EXPORT ------------------------------------------------------------------------

today <- lubridate::today()

write_csv(df_psnu_tst, glue::glue("Dataout/df_psnu_tst_{today}.csv" ))
