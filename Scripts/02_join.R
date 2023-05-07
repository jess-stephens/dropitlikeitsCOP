





#bind plhiv and all tabs for import into Tableau
dp_final <- bind_rows(dp_filtered, dp_plhiv_filtered)
# %>% 
# mutate(agency_lookback = funding_agency)