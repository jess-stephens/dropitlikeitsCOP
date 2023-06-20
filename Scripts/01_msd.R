# Project: dropitlikeitsCOP
# Script: 01_msd
# Developers: Jessica Stephens (USAID)
# Use: to munge the MSD into the following indicators to align with TST / DP:  
###IP	indicator	snu	psnu	age_coarse	sex	result_target		fy_qtr value###

data_folder <- "C:/Users/jstephens/Documents/Zim/COP23/dropitlikeitsCOP/Data"


#IMPORT ------------------------------------------------------------------------

df<-read_psd("dropitlikeitsCOP/Data/MER_Structured_Datasets_PSNU_IM_FY21-23_20230210_v1_1_Zimbabwe.txt")

msd_disagg_map <- data_folder %>% 
  return_latest("msd_disagg_mapping.xlsx") %>% 
  read_excel()

tst_indicators <- data_folder %>% 
  return_latest("tst_disags_mapping.xlsx") %>% 
  read_excel(sheet="standarddisag")

otherdisag <- data_folder %>% 
  return_latest("tst_disags_mapping.xlsx") %>% 
  read_excel(sheet="otherdisag", na="NA")
# ^^^ issues using, leading to manual entry

age_map <- data_folder %>% 
  return_latest("age_mapping.xlsx") %>% 
  read_excel()


#MUNGE ------------------------------------------------------------------------

#reshape long
df_reshape<- reshape_msd(df, qtrs_keep_cumulative = TRUE)
names(df_reshape)

# test<-df_reshape %>%
#     distinct(prime_partner_name, mech_code,mech_name)


#minimize size
##select necessary indicators
df_indicators<-df_reshape %>% 
  select(c( prime_partner_name, snu1, psnu,indicator, numeratordenom, 
           standardizeddisaggregate, otherdisaggregate,modality,
           trendscoarse, sex,  period, period_type, value)) 
## select necessary rows
df_rows<-df_indicators %>% 
  filter(period_type=="cumulative",
         period=="FY22")

#reshape indicator numeratordenom (no denominators needed, expect for PVLS_D)
df_rows_nd<-df_rows %>% 
  mutate(numeratordenom=if_else(numeratordenom=="D", "D","")) %>% 
  mutate(indicator=if_else(numeratordenom=="D", paste(indicator,numeratordenom, sep = "_"), indicator)) %>% 
  select(!c(numeratordenom))

## QUICK CHECKS
# standard1<-df_rows_nd %>% 
#   filter(indicator=="TX_TB_D") %>% 
#     distinct(indicator,standardizeddisaggregate, otherdisaggregate)


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

## QUICK CHECKS
# unique(tst_indicator_list$standardizeddisaggregate)
# unique(tst_indicator_list$otherdisaggregate)


#########################################################################
#map to TST other disaggregrates
#########################################################################
# Collapse across standdardized disaggregates to removed otherdisaggregates
# #can change otherdisaggregate to na then group all afterwards
# CXCA_SCRN
# HTS_RECENT
# HTS_SELF
# 
# # Select other disaggregate =  NA
# HTS_INDEX 
# VMMC_CIRC
# #check modalities below when doing this
# HTS_TST
# HTS_TST_POS

# # Select other disaggregate !=  Recent
# PMTCT_STAT
# 
# # Select other disaggregate =  Routine
# TX_PVLS
# TX_PVLS_D

# matches fine, no changes
# OVC_SERV
# PMTCT_ART
# PMTCT_STAT_D
# PMTCT_EID
# PP_PREV
# Prep_CT
# PREP_NEW
# TB_ART
# TB_PREV
# TB_PREV_D
# TB_STAT
# TB_STAT_D
# TX_CURR
# TX_NEW
# TX_TB_D


tst_otherdisag <- tst_indicator_list %>% 
  mutate(otherdisaggregate = case_when(
    indicator=="CXCA_SCRN"~NA,
    indicator=="HTS_RECENT"~NA,
    indicator=="HTS_SELF"~NA,
      grepl("Already", otherdisaggregate) ~ "Already",
    grepl("New", otherdisaggregate) ~ "New",
    otherdisaggregate == "Known at Entry" ~ "Known",

    TRUE ~ otherdisaggregate
  )) %>% 
  filter(!(indicator=="HTS_INDEX" & !is.na(otherdisaggregate)), 
         !(indicator=="VMMC_CIRC" & !is.na(otherdisaggregate)), 
         !(indicator=="HTS_TST" & !is.na(otherdisaggregate)),
         !(indicator=="HTS_TST_POS" & !is.na(otherdisaggregate)), 
         !(indicator=="PMTCT_STAT" & (otherdisaggregate=="Recent")), 
         !(indicator=="TX_PVLS" & (otherdisaggregate=="Targeted")),
         !(indicator=="TX_PVLS_D" & (otherdisaggregate=="Targeted")) 
  )

## QUICK CHECKS
# other_psnu<-dp_munge %>% distinct(indicator,standardizeddisaggregate,otherdisaggregate)
# other2<-tst_otherdisag %>% distinct(indicator, standardizeddisaggregate, otherdisaggregate)

tst_otherdisag_group<-tst_otherdisag %>% 
  dplyr::group_by_if(is.character) %>%
  dplyr::summarise_if(is.numeric, ~ sum(., na.rm = TRUE)) %>% 
  ungroup()


##############################################################
# CREATE SECONDARY DF BY SNU TO JOIN TO PSNU DF

# collapse by snu trends
df_snu<- tst_otherdisag_group %>% 
  dplyr::select(!c(psnu, period_type, modality)) %>% 
  dplyr::group_by_if(is.character) %>%
  dplyr::summarise_if(is.numeric, ~ sum(., na.rm = TRUE))%>% 
  rename(value_snu1=value)

df_psnu<-tst_otherdisag_group %>% 
  dplyr::select(!c( period_type, modality)) %>% 
  rename(value_psnu=value) 


##############################################################
# JOIN SNU COLUMN BACK TO DF_PSNU

df_wide<- left_join(
  df_psnu, df_snu)
  
# CALCULATE RATIO OF PSNU TO SNU

df_ratio_stdev<-df_wide %>% 
  mutate(FY22_ratios=value_psnu/value_snu1) %>% 
  select(!c(value_psnu, value_snu1, period))

#CHECK ------------------------------------------------------------------------
# COMPARE TO DP_COLLAPSE (ALIGN_DP IN 01_TST_PSNU.R)

# align<-df_ratio_stdev %>%
#   select(c(indicator, standardizeddisaggregate, otherdisaggregate)) %>%
#   unique()

# unique(df_msd$prime_partner_name)


#EXPORT ------------------------------------------------------------------------

 today <- lubridate::today()
 
 write_csv(df_ratio_stdev, glue::glue("Dataout/df_msd_ratio_stdev_{today}.csv" ))
