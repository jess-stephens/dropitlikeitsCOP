# Project: dropitlikeitsCOP
# Script: 01_TST_PSNU
# Developers: Jessica Stephens (USAID)
# Use: to munge the TST by age to align with MSD coarse:  

#IMPORT ------------------------------------------------------------------------

# IMPORT DATA: TST

data_folder <- "C:/Users/jstephens/Documents/Zim/COP23/dropitlikeitsCOP/Data"

psnu <- data_folder %>% 
  return_latest("PSNUxIM")

dp <- tame_dp(psnu, type="PSNUxIM")

# names(dp)

#MUNGE ------------------------------------------------------------------------

#match to IP names from DATIM
datim_user_nm <- "jstephens@usaid.gov" 
datim_pwd <- getPass::getPass()
dp_names <- get_names(dp, datim_user = datim_user_nm, datim_password = datim_pwd)

dp_indicators<-dp_names %>% 
  select(c( prime_partner_name, psnu,indicator, numeratordenom, mech_code,
            standardizeddisaggregate, otherdisaggregate,modality,
            ageasentered, sex,  fiscal_year, targets)) 

# mutate FY
# change fy to period and period type

dp_period <- dp_indicators %>%
  clean_indicator() %>% 
  mutate(fiscal_year = as.character(fiscal_year)) %>% 
  mutate(fiscal_year = "FY24Q4") %>%
  mutate(period_type="targets") %>% 
  rename(period=fiscal_year, value=targets) %>% 
  select(!c(numeratordenom))

# qc_tst_names<-dp_period %>%
#   select(c(prime_partner_name, mech_code)) %>%
#   unique()

dp_mech<-dp_period %>% 
mutate(prime_partner_name=case_when(
  mech_code=="87685"~ "Population Services International",
  mech_code=="87082"~ "UNIVERSITY OF WASHINGTON",
  TRUE~prime_partner_name)) %>% 
  select(!(mech_code)) %>% 
  filter(prime_partner_name=="Centre for Sexual Health and HIV/AIDS Research Zimbabwe"|
                               prime_partner_name=="ORGANIZATION FOR PUBLIC HEALTH INTERVENTIONS AND DEVELOPMENT"|
                               prime_partner_name=="Population Services International"|
                               prime_partner_name=="UNIVERSITY OF WASHINGTON"|
                               prime_partner_name=="ZIMBABWE ASSOCIATION OF CHURCH RELATED HOSPITAL"|
                               prime_partner_name=="Zimbabwe Health Interventions") 


# rename psnu to snu1
#change ageasentered to coarse trends

dp_munge<-dp_mech %>% 
  rename(snu1=psnu, FY24_target_snu=value)  %>% 
  filter(!is.na(ageasentered)) %>% 
    mutate(trendscoarse=ifelse(
    ageasentered %in%  c("01-09","02 - 12 Months", "<=02 Months", "<15","<01",
                         "01-04","05-09","10-14"),
                            "<15", "15+"))%>% 
  select(!c(ageasentered,period, period_type, modality))

# collapse by coarse trends
dp_collapse<- dp_munge %>% 
  dplyr::group_by_if(is.character) %>%
  dplyr::summarise_if(is.numeric, ~ sum(., na.rm = TRUE)) %>% 
  ungroup()

#CHECK ------------------------------------------------------------------------
# COMPARE TO MSD (ALIGN IN 01_MSD.R)

# dp_collapse<-df_dp_tst %>%
#   select(c(indicator, standardizeddisaggregate, otherdisaggregate)) %>%
#   unique()

# unique(df_dp_tst$prime_partner_name)

#EXPORT ------------------------------------------------------------------------


today <- lubridate::today()

write_csv(dp_collapse, glue::glue("Dataout/dp_collapse_{today}.csv" ))


