## MSD Munge
# IP	indicator	snu	psnu	age_coarse	sex	result_target		fy_qtr value

data_folder <- "C:/Users/jstephens/Documents/Zim/COP23/dropitlikeitsCOP/Data"

msd_disagg_map <- data_folder %>% 
  return_latest("msd_disagg_mapping.xlsx") %>% 
  read_excel()

df<-read_psd("Data/MER_Structured_Datasets_PSNU_IM_FY21-23_20230210_v1_1_Zimbabwe.txt")
names(df)

df_reshape<- reshape_msd(df, qtrs_keep_cumulative = TRUE)
names(df_reshape)
df_indicators<-df_reshape %>% 
  select(c( prime_partner_name, snu1, psnu,indicator, indicatortype, numeratordenom, 
           standardizeddisaggregate, otherdisaggregate,modality,
           trendscoarse, sex,  period, period_type, value)) 
  
df_rows<-df_indicators %>% 
  filter(period_type=="cumulative",
         period=="FY22")

# collapse by snu trends
df_snu<- df_rows %>% 
  select(!c(psnu, period_type)) %>% 
  dplyr::group_by_if(is.character) %>%
  dplyr::summarise_if(is.numeric, ~ sum(., na.rm = TRUE))%>% 
  rename(value_snu1=value)

df_psnu<-df_rows %>% 
  rename(value_psnu=value) %>% 
  select(!c(period_type)) 
  

#join back
df_wide<- left_join(
  df_psnu, df_snu)
  
df_ratio<-df_wide %>% 
  mutate(FY22_ratios=value_psnu/value_snu1) %>% 
  select(!c(period))


today <- lubridate::today()

write_csv(df_ratio, glue::glue("Dataout/df_msd_ratio_{today}.csv" ))
