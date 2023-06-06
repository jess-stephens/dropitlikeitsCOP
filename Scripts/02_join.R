# Project: dropitlikeitsCOP
# Script: 01_msd
# Developers: Jessica Stephens (USAID)
# Use: to join the munged data sources for MSD, TST and KP targets

############################################################################

#IMPORT ------------------------------------------------------------------------


names(df_ratio) #MSD MUNGED
names(dp_collapse) #TST MUNGED

#need to subtract KP targets from dp_collapse before this join
# names(df_kp)

#JOIN ------------------------------------------------------------------------

#JOIN FY24 TST GP TARGETS TO MSD FY22 RATIOS & APPLY

#CHECK IP NAMES ACROSS YEARS AND FIX

# replace dp collapse with df_psnu_tst_gp after kp removal from plhiv targets
#replace FY24_target_snu with fy24_target_gp after kp removal from plhiv targets
df_psnu_tst<- left_join(
  dp_collapse, df_ratio, 
  multiple="all") %>% 
  # select(prime_partner_name, snu1, psnu, indicator, indicatortype, numeratordenom, 
  #        standardizeddisaggregate, otherdisaggregate, modality, sex, trendscoarse, 
  #        FY22_ratios, FY23_target_snu) %>% 
  select(prime_partner_name, snu1, indicator, indicatortype,
         standardizeddisaggregate,  otherdisaggregate, sex, trendscoarse,
         FY22_ratios, FY24_target_snu) %>%
  mutate(FY24_target_psnu=FY24_target_snu * FY22_ratios) 


df_ratio_stdev

#KP MUNGE ----------------------------------------------------------------------



#EXPORT ------------------------------------------------------------------------

today <- lubridate::today()

write_csv(df_psnu_tst, glue::glue("Dataout/df_psnu_tst_{today}.csv" ))
