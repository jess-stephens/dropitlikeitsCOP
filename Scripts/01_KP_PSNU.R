# Project: dropitlikeitsCOP
# Script: 01_msd
# Developers: Jessica Stephens (USAID)
# Use: to munge the KP PSNU targets with two goals to maintain KP PSNU targets: 
### 1) subtract KP SNU targets from full PLHIV estimates at SNU
### 2) apply KP PSNU / SNU ratios or KP PSNU spread to GP PSNU targets

##################################################################

#IMPORT ------------------------------------------------------------------------

# IMPORT DATA: KP PSNU TARGETS
data_folder <- "C:/Users/jstephens/Documents/Zim/COP23/dropitlikeitsCOP/Data"

df_kp <- data_folder %>% 
  return_latest("KP") %>% 
  read_excel(sheet="Prevention_NonKP_Targets")


#CLEAN ------------------------------------------------------------------------

df_kp_clean <- df_kp %>% 
  clean_names() %>% 
  rename(prime_partner_name=partner,snu1=province, psnu=district, 
         standardizeddisaggregate=disaggregate, fy24_target_kp=target)

# CLEAN PARTNER NAMES TO MATCH MSD FY22

df_kp_clean2<-df_kp_clean %>% 
  mutate(prime_partner_name=case_when(
    prime_partner_name=="CesHHAR"~ "Centre for Sexual Health and HIV/AIDS Research Zimbabwe",
    prime_partner_name=="CeSHHAR"~ "Centre for Sexual Health and HIV/AIDS Research Zimbabwe",
    prime_partner_name=="Mavambo"~ "Mavambo Orphan Care",
    prime_partner_name=="OPHID"~ "ORGANIZATION FOR PUBLIC HEALTH INTERVENTIONS AND DEVELOPMENT",
    prime_partner_name=="Prevent"~ "Population Services International",
    prime_partner_name=="CLINICAL IP TBD"~ "UNIVERSITY OF WASHINGTON",
    prime_partner_name=="ZACH"~ "ZIMBABWE ASSOCIATION OF CHURCH RELATED HOSPITAL",
    prime_partner_name=="ZHI ACCE"~ "Zimbabwe Health Interventions",
    prime_partner_name=="Bantwana"~ "BANTWANA ZIMBABWE",
    TRUE~prime_partner_name)) %>% 
  filter(prime_partner_name=="Centre for Sexual Health and HIV/AIDS Research Zimbabwe"|
           prime_partner_name=="ORGANIZATION FOR PUBLIC HEALTH INTERVENTIONS AND DEVELOPMENT"|
         prime_partner_name=="Population Services International"|
         prime_partner_name=="UNIVERSITY OF WASHINGTON"|
         prime_partner_name=="ZIMBABWE ASSOCIATION OF CHURCH RELATED HOSPITAL"|
         prime_partner_name=="Zimbabwe Health Interventions") %>% 
  filter(!is.na(psnu))

#MUNGE ------------------------------------------------------------------------
# df_kp_clean3 %>% 
#   dplyr::select(c( fy24_target_kp)) %>% 
#   dplyr::group_by_if(is.character) %>%
#   dplyr::summarise_if(is.numeric, ~ sum(., na.rm = TRUE))%>% 
#   ungroup()
#458837

#change ageasentered to coarse trends
df_kp_munge<-df_kp_clean2 %>% 
  mutate(trendscoarse=ifelse(
    age %in%  c("1-4","5-9", "<1", "10-14","<01"),
    "<15", "15+"))%>% 
  select(!c(age)) 


#remove kp type from prep_ct and prep_new in order to collapse
#drop pp_prev HIV+ - just keep na
#drop agyw_prev denominator
#drop ovc_serv dreams and preventive

# unique(df_kp_munge_collapse$standarddizeddisaggregate)
# # "Denominator" "Numerator"   "Active"      "Graduated"   "DREAMS"      
# # "Preventive"  "(HIV+)"      NA            "FSW"        
# #  "MSM"         "TG"    
df_kp_munge2<-df_kp_munge %>% 
  mutate(standardizeddisaggregate=ifelse(
    indicator=="PrEP_NEW" | indicator=="PrEP_CT", NA, standardizeddisaggregate))%>%
  mutate(indicator=ifelse(
    indicator=="PREP_NEW", "PrEP_NEW", indicator))%>%
  mutate(indicator=ifelse(
    indicator=="PREP_CT", "PrEP_CT", indicator))%>%
  filter(!(indicator=="AGYW_PREV" & standardizeddisaggregate=="Denominator"), 
         !(indicator=="OVC_SERV" & standardizeddisaggregate=="DREAMS"), 
         !(indicator=="OVC_SERV" & standardizeddisaggregate=="Preventive"),
        !(indicator=="PP_PREV" & !is.na(standardizeddisaggregate)))

# align_kp<-df_kp_munge %>%
#   # filter(indicator=="PrEP_CT") %>%
#   select(c(indicator, standardizeddisaggregate)) %>%
#   unique()

df_kp_munge3<-df_kp_munge2 %>% 
  mutate(sex=case_when(
    standardizeddisaggregate %in%  c("MSM","TG")~    "Male",
    standardizeddisaggregate=="FSW"~  "Female",
    standardizeddisaggregate=="PWID"~  "Male",
    standardizeddisaggregate=="People in prisons and other enclosed settings"~  "Male",
    indicator=="GEND_GBV"~  "Female",
    TRUE~sex))

# collapse by coarse trends
# df_kp_munge_collapse<- df_kp_munge3 %>% 
#   dplyr::group_by_if(is.character) %>%
#   dplyr::summarise_if(is.numeric, ~ sum(., na.rm = TRUE)) %>% 
#   ungroup() %>% 
# view()

df_kp_munge_collapse<- df_kp_munge3 %>% 
  select(!standardizeddisaggregate) %>% 
  dplyr::group_by_if(is.character) %>%
  dplyr::summarise_if(is.numeric, ~ sum(., na.rm = TRUE)) %>% 
  ungroup()

##############################################################
# CREATE SECONDARY DF BY SNU ( MAY JOIN TO PSNU DF for realignment)

# collapse by snu trends
df_kp_snu<- df_kp_munge_collapse %>% 
  dplyr::select(!c(psnu, agency)) %>% 
  dplyr::group_by_if(is.character) %>%
  dplyr::summarise_if(is.numeric, ~ sum(., na.rm = TRUE))%>% 
  rename(fy24_target_snu_kp=fy24_target_kp) %>% 
  ungroup() 

# rename target in psnu file 
df_kp_psnu<-df_kp_munge_collapse %>%   
  dplyr::select(!c( agency)) %>% 
  rename(fy24_target_psnu_kp=fy24_target_kp)


##############################################################
# SHOULD NEED THIS FOR RE-ALIGNMENT OF KP INDICATORS
# MAY ALSO NEED KP TYPE / ST DEV BACK
# JOIN SNU COLUMN BACK TO DF_PSNU

df_kp_wide<- left_join(
  df_kp_psnu, df_kp_snu)

# CALCULATE RATIO OF PSNU TO SNU

df_kp_ratio<-df_kp_wide %>% 
  mutate(fy24_ratios_kp=fy24_target_psnu_kp/fy24_target_snu_kp)





#EXPORT ------------------------------------------------------------------------

today <- lubridate::today()
write_csv(df_kp_ratio, glue::glue("Dataout/df_kp_ratio_{today}.csv" ))

write_csv(df_kp_snu, glue::glue("Dataout/df_kp_snu_join_{today}.csv" ))

# write_csv(df_kp_ratio, glue::glue("Dataout/df_kp_ratio_{today}.csv" ))
  
  
  