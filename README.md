# dropitlikeitsCOP
Dropping SNU targets to PSNU

## Overview
In COP23, some PEPFAR Operating Units (OUs) raised the geographic level of annual indicator target setting levels. The geographic levels for these OU's transition from from the PSNU (i.e. district) to the SNU (i.e. province, a higher level). As PEPFAR approaches Epidemic Control (UNAIDS 95-95-95), the level of granularity for funding agency targeting can decrease, while maintaining programmatic focus at the last mile. 
This process also decreases the level of effort invested in the Target Setting Tool (TST, formerally known as the DataPack). However, Implementing Partners (IPs) are used to recieving granular PSNU-level targets. To lessen the burden on IPs during transition to SNU in the target setting process, we have bridged the gap by extrapolating 

## Case Study
The PEPFAR Interagency Strategic Informations (SI) Technical Working Group (TWG) in Zimbabwe requested Interagency Collaborative for Program Improvement (ICPI) support to delgate COP23 targets from the SNU (completed in the COP23 Target Setting Tool) to PSNU level. This code is based on the project completed for Zimbabwe. 

## Data Sources
### Required
* TST PSNUxIM
* MSD
### Optional 
* Prevention and Key Populations PSNU level targets (used by Zimbabwe)
  + Zimbabwe already set Prevention and KP targets at PSNU, so these had to be included, but other OUs may not have these targets at the PSNU level. If that is the case then additional disaggregate and age mapping *may* be necessary. 
* Spectrum output (necessary if assumption #2, below, is utilized)

## Assumptions

### There are various methodologies explored to set PSNU targets according **PSNU / SNU size ratios**:  

#### 1. Prior years' results  
a.k.a Different ratio by indicator 
* Must decide on which period and be consistent across indicators. Some options include:
	+ FY22 cumulative / apr **(option selected by Zimbabwe, in this code)**
	+ FY23Q1 
 	+ Average of last 4 quarters 
* Pros:
  + Ex high targets where high numbers 
* Cons:
  + Issues for new disaggregates 
  + Assumes trend continues, maintains status quo
  + Does Not respond to where we traditionally are not performing well 


#### 2. PLHIV estimates by AGE / SEX at PSNU level 
a.k.a One standard ratio per PSNU 
* Pros:
  + Respond to epidemic picture 
* Cons:
  + Challenges with estimates outputs
  + May not be responding to reality (aka peds)

---

*Disclaimer: The findings, interpretation, and conclusions expressed herein are those of the authors and do not necessarily reflect the views of United States Agency for International Development. All errors remain our own.*
