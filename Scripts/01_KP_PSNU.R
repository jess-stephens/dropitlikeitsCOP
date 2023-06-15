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
         standardizeddisaggregate=disaggregate, FY24_target_kp=target)
  
  
# unique(df_kp$partner)

# mutate(mech_number=case_when((
#   partner=="Bantwana" ~ " ",
#   partner=="ZHI RISE"~,
#   partner=="CesHHAR"~"",
#   partner=="Prevent"~"",
#   partner=="ZHI ACCE"~"",
#   partner=="OPHID"~"",
#   partner=="CLINICAL IP TBD"~"",
#   partner=="Mavambo"~"",
#   partner=="ZACH"~"",
#   partner=="FACT SPACE 4 OVC"~"",
#   partner=="FACT SMART Girls"~"",
#   partner=="DREAMS IP TBD"~"",
#   partner=="HOSPAZ"~"",
#   partner=="OU"~"",
#   
# )))


#MUNGE ------------------------------------------------------------------------

may need to check age = NA

#change ageasentered to coarse trends
df_kp_munge<-df_kp_clean %>% 
  filter(!is.na(age)) %>% 
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

# collapse by coarse trends
df_kp_munge_collapse<- df_kp_munge2 %>% 
  dplyr::group_by_if(is.character) %>%
  dplyr::summarise_if(is.numeric, ~ sum(., na.rm = TRUE)) %>% 
  ungroup() %>% 
view()

# align_kp<-df_kp_munge2 %>%
#   select(c(indicator, standardizeddisaggregate)) %>%
#   unique()


##############################################################
# CREATE SECONDARY DF BY SNU TO JOIN TO PSNU DF

# collapse by snu trends
df_kp_snu<- df_kp_munge_collapse %>% 
  dplyr::select(!c(psnu)) %>% 
  dplyr::group_by_if(is.character) %>%
  dplyr::summarise_if(is.numeric, ~ sum(., na.rm = TRUE))%>% 
  rename(fy24_target_snu_kp=FY24_target_kp)

df_kp_psnu<-df_kp_munge_collapse %>% 
  rename(fy24_target_psnu_kp=FY24_target_kp)

##############################################################
# JOIN SNU COLUMN BACK TO DF_PSNU

df_kp_wide<- left_join(
  df_kp_psnu, df_kp_snu)

# CALCULATE RATIO OF PSNU TO SNU

df_kp_ratio<-df_wide %>% 
  mutate(fy24_ratios_kp=fy24_target_psnu_kp/fy24_target_snu_kp)



##############################################################
#REJOIN SNU VALUES TO PSNU DATA
df_kp_snu_join<-df_kp_ratio %>% 
  select(!c(psnu, agency, fy24_target_psnu_kp))

##############################################################
CLEAN PARTNER NAMES

#EXPORT ------------------------------------------------------------------------

today <- lubridate::today()
  
write_csv(df_kp_snu_join, glue::glue("Dataout/df_kp_snu_join_{today}.csv" ))

write_csv(df_kp_ratio, glue::glue("Dataout/df_kp_ratio_{today}.csv" ))
  
  
  