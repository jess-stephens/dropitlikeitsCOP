


data_folder <- "C:/Users/jstephens/Documents/Zim/COP23/dropitlikeitsCOP/Data"




psnu <- data_folder %>% 
  return_latest("PSNUxIM")

dp <- tame_dp(psnu, type="PSNUxIM")
names(dp)

#match to IP names from DATIM
datim_user_nm <- "jstephens@usaid.gov" 
datim_pwd <- getPass::getPass()
dp_names <- get_names(dp, datim_user = datim_user_nm, datim_password = datim_pwd)


dp_indicators<-dp_names %>% 
  select(c( prime_partner_name, psnu,indicator,indicatortype, numeratordenom, 
            standardizeddisaggregate, otherdisaggregate,modality,
            ageasentered, sex,  fiscal_year, targets)) 

# mutate FY
dp_period <- dp_indicators %>%
  clean_indicator() %>% 
  mutate(fiscal_year = as.character(fiscal_year)) %>% 
  mutate(fiscal_year = "FY24Q4") %>% 
  rename(period=fiscal_year)
         
# change fy to period and period type

# rename psnu to snu1
#change ageasentered to coarse trends

dp_munge<-dp_period %>% 
  rename(snu1=psnu)  %>% 
  filter(!is.na(ageasentered)) %>% 
    mutate(coarsetrends=ifelse(
    ageasentered %in%  c("01-09","02 - 12 Months", "<=02 Months", "<15","<01",
                         "01-04","05-09","10-14"),
                            "<15", "15+")) %>% 
  select(!ageasentered)

# collapse by coarse trends
dp_collapse<- dp_munge %>% 
  dplyr::group_by_if(is.character) %>%
  dplyr::summarise_if(is.numeric, ~ sum(., na.rm = TRUE)) 



today <- lubridate::today()


