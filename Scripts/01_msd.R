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
  filter(period_type!="results",
         period=="FY22")

indicators<-unique(df_rows$indicator)






today <- lubridate::today()
