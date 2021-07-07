cd "C:\Users\emman\Dropbox\Documents\Data\India Data\NSS\NSS EUS 68"
use block_5_1_principal_activity, clear

ren State state
lab var state "state code"

ren District_code dist_code
lab var dist_code "district code"

ren Sector sector
lab var sector "rural or urban"

ren Stratum stratum
lab var stratum "stratum"

ren Sub_Stratum_No substratum
lab var substratum "substratum"

ren FSU_Serial_No psu
lab var psu "primary survey unit (village/block)"

ren Hamlet_Group_Sub_Block_No hamlet_subblock
lab var hamlet_subblock "hamlet group or sub-block number"

ren Second_Stage_Stratum_No ss_strata_no
lab var ss_strata_no "second stage stratum number"

ren Sample_Hhld_No household
lab var household "represents the nth household within each of the second stage stratum"

ren Person_Serial_No person
lab var person "identifier for individual respondent"

ren Age age
lab var age "age of respondent"

ren Usual_Principal_Activity_Status upas_code
lab var upas_code "Usual principal activity status code"

ren HHID hhid
lab var hhid "household identifier"

ren Multiplier_comb pweight
lab var pweight "probability weight (combined multiplier)"

keep state dist_code sector stratum substratum psu pweight hamlet_subblock ss_strata_no household hhid person age upas_code
