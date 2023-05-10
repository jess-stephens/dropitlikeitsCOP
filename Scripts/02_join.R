
#need to subtract KP targets from dp_collapse before this join

names(df_ratio)
names(dp_collapse)

#join back
df_psnu_tst<- left_join(
  dp_collapse, df_ratio, 
  multiple="all") %>% 
  select(prime_partner_name, snu1, psnu, indicator, indicatortype, numeratordenom, 
         standardizeddisaggregate, otherdisaggregate, modality, sex, trendscoarse, 
         FY22_ratios, FY23_target_snu) %>% 
  mutate(FY23_target_psnu=FY23_target_snu * FY22_ratios)



today <- lubridate::today()

write_csv(df_psnu_tst, glue::glue("Dataout/df_psnu_tst_{today}.csv" ))