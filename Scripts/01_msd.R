## MSD Munge
# IP	indicator	snu	psnu	age_coarse	sex	result_target		fy_qtr value

data_folder <- "C:/Users/jstephens/Documents/Zim/COP23/dropitlikeitsCOP/Data"


#IMPORT ------------------------------------------------------------------------

df<-read_psd("Data/MER_Structured_Datasets_PSNU_IM_FY21-23_20230210_v1_1_Zimbabwe.txt")

msd_disagg_map <- data_folder %>% 
  return_latest("msd_disagg_mapping.xlsx") %>% 
  read_excel()

tst_indicators <- data_folder %>% 
  return_latest("tst_disags_mapping.xlsx") %>% 
  read_excel(sheet="standarddisag")

otherdisag <- data_folder %>% 
  return_latest("tst_disags_mapping.xlsx") %>% 
  read_excel(sheet="otherdisag")

age_map <- data_folder %>% 
  return_latest("age_mapping.xlsx") %>% 
  read_excel()


#MUNGE ------------------------------------------------------------------------

#reshape long
df_reshape<- reshape_msd(df, qtrs_keep_cumulative = TRUE)

#minimize size 
df_indicators<-df_reshape %>% 
  select(c( prime_partner_name, snu1, psnu,indicator, indicatortype, numeratordenom, 
           standardizeddisaggregate, otherdisaggregate,modality,
           trendscoarse, sex,  period, period_type, value)) 

df_rows<-df_indicators %>% 
  filter(period_type=="cumulative",
         period=="FY22")


#reshape indicator numeratordenom
df_rows_nd<-df_rows %>% 
  mutate(numeratordenom=if_else(numeratordenom=="D", "D","")) %>% 
  mutate(indicator=if_else(numeratordenom=="D", paste(indicator,numeratordenom, sep = "_"), indicator)) %>% 
  select(!c(numeratordenom))

# #mutate age bands
# df_age_adj <- df_filtered %>% 
#   left_join(age_map, by = c("indicator", "ageasentered" = "age_msd")) %>% 
#   mutate(age_dp = ifelse(is.na(age_dp), ageasentered, age_dp)) %>% 
#   select(-ageasentered) %>% 
#   group_by(across(-c(cumulative))) %>% 
#   summarise(across(c(cumulative), sum, na.rm = TRUE), .groups = "drop") 

#map to TST standardizeddisaggregates
#filter to only 13 indicators from TST
tst_indicator_list<-df_rows_nd %>% 
  left_join(tst_indicators, by=c("indicator", "standardizeddisaggregate"="FY22")) %>% 
  filter(!is.na(FY24)) %>% 
  select(!c("standardizeddisaggregate"))%>% 
  rename(standardizeddisaggregate=FY24) 


########################STUCK###############################################
#map to TST other disaggregrates
tst_otherdisag<-tst_indicator_list %>% 
  left_join(otherdisag, by=c("indicator", "otherdisaggregate"="MSD"), multiple = "all")



other<-tst_indicator_list %>% distinct(indicator,standardizeddisaggregate, otherdisaggregate)
##########################################################################


# collapse by snu trends
df_snu<- tst_indicator_list %>% 
  select(!c(psnu, period_type)) %>% 
  dplyr::group_by_if(is.character) %>%
  dplyr::summarise_if(is.numeric, ~ sum(., na.rm = TRUE))%>% 
  rename(value_snu1=value)

df_psnu<-tst_indicator_list %>% 
  rename(value_psnu=value) %>% 
  select(!c(period_type)) 
  

#join back
df_wide<- left_join(
  df_psnu, df_snu)
  
df_ratio<-df_wide %>% 
  mutate(FY22_ratios=value_psnu/value_snu1) %>% 
  select(!c(period))

df_ratio_stdev<-df_wide %>% 
  mutate(FY22_ratios=value_psnu/value_snu1) %>% 
  select(!c(otherdisaggregate, modality))

align<-df_ratio_stdev %>% 
  select(c(indicator, standardizeddisaggregate)) %>% 
  unique()


# df_stdev_names<-df_ratio_stdev %>% 
#   mutate(standardizeddisaggregate=
#            case_when(
#              indicator=="CXCA_SCRN"~ "Age/Sex/HIVStatus",
#              indicator=="HTS_INDEX"~"Age/Sex/Result",
#              indicator=="HTS_RECENT"~"Age/Sex/HIVStatus",
#              
#               standardizeddisaggregate))


today <- lubridate::today()

write_csv(df_ratio_stdev, glue::glue("Dataout/df_msd_ratio_stdev_{today}.csv" ))
