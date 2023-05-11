
#need to subtract KP targets from dp_collapse before this join

#COLLAPSE KP TARGETS FROM PSNU TO SNU (USING PSNU KP FILE)

#LEFT JOIN OF KP TARGETS AT SNU TO DP COLLAPSE
df_psnu_tst<- left_join(
  dp_collapse, #KP_df)
  
  
#SUBTRACT KP FROM GP
#fy24_target_snu

------------
#IN THE KP PSNU, FIND THE PERCENT CONTRIBUTION OF EACH PSNU TO THE SNU
  # SNU=100
  # PSNU1 KP=10 KP CONTRIBUTION = .1
  # PSNU2 KP=10 KP CONTRIBUTION =.1
  # PSNU3 KP=80 KP CONTRIBUTION =.8 

  

names(df_ratio) #MSD MUNGED
names(dp_collapse) #TST MUNGED

#join back
df_psnu_tst<- left_join(
  dp_collapse, df_ratio, 
  multiple="all") %>% 
  select(prime_partner_name, snu1, psnu, indicator, indicatortype, numeratordenom, 
         standardizeddisaggregate, otherdisaggregate, modality, sex, trendscoarse, 
         FY22_ratios, FY23_target_snu) %>% 
  mutate(FY23_target_psnu=FY23_target_snu * FY22_ratios) 


df_ratio_stdev



today <- lubridate::today()

write_csv(df_psnu_tst, glue::glue("Dataout/df_psnu_tst_{today}.csv" ))