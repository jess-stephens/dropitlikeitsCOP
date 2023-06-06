# Project: dropitlikeitsCOP
# Script: 01_msd
# Developers: Jessica Stephens (USAID)
# Use: to munge the KP PSNU targets with two goals to maintain KP PSNU targets: 
### 1) subtract KP SNU targets from full PLHIV estimates at SNU
### 2) apply KP PSNU / SNU ratios or KP PSNU spread to GP PSNU targets

##################################################################

#IMPORT ------------------------------------------------------------------------

# IMPORT DATA: KP PSNU TARGETS
data_folder <- "C:/Users/jstephens/Documents/Zim/COP23/dropitlikeitsCOP/Data"

df_kp <- data_folder %>% 
  return_latest("KP")

#MUNGE ------------------------------------------------------------------------

# COLLAPSE KP TARGETS FROM PSNU TO SNU (USING PSNU KP FILE)
## does it have the snu or do we need to join based on MSD? 

# CREATE TWO KP DATASETS

# df_kp_snu collapses psnu targets to snu, in order to subtract from dp_collapse
## name target: fy24_target_snu_kp
### change group by below - this is an example - 

dp_kp_snu<- df_kp %>% 
  # dplyr::group_by_if(is.character) %>%
  # dplyr::summarise_if(is.numeric, ~ sum(., na.rm = TRUE)) %>% 
  ungroup()


# df_kp_ratio has all the psnu targets side by side with snu targets (calc ratio) 
## ^df_kp_ratio joins back the collapsed df_kp_snu
####### when to apply this? #######



#LEFT JOIN OF KP TARGETS AT SNU TO DP COLLAPSE
#add 1 column of fy24_target_snu_kp

df_psnu_tst_kp<- left_join(
  dp_collapse, df_kp_snu)

#SUBTRACT KP FROM PLHIV TARGETS AT SNU LEVEL
 df_psnu_tst_gp<- df_psnu_tst_kp %>% 
  mutate(fy24_target_gp = fy24_target_snu - fy24_target_snu_kp)



#------------ CONCEPT 
  #IN THE KP PSNU, FIND THE RATIO / PERCENT CONTRIBUTION OF EACH PSNU TO THE SNU
  # SNU=100
  # PSNU1 KP=10 KP CONTRIBUTION = .1
  # PSNU2 KP=10 KP CONTRIBUTION =.1
  # PSNU3 KP=80 KP CONTRIBUTION =.8 


#EXPORT ------------------------------------------------------------------------

today <- lubridate::today()
  
# write_csv(***, glue::glue("Dataout/***_{today}.csv" ))
  
  
  