*SET PATH HERE TO THE "Clean Data" FOLDER
global dirpath "C:\Users\ecmyers\Dropbox\AHS\Replication\Clean Data"

*SET PATH WHERE YOU WANT TO SAVE TABLE 1 HERE
cd "C:\Users\ecmyers\Dropbox\AHS\Replication\Tables"

*********************************************************************************************************************************************************************************
*TABLE 1:
*********************************************************************************************************************************************************************************

use "$dirpath\renter_full", clear
collapse(mean) bedrms rooms halfb baths nunits degree dry dish built_middle metro3 built_bin air airsys mod sev inc_real oil opu, by(control)

*use most common fuel type and payment regime in the unit for summary stats
replace oil = 1 if oil>=0.5
replace oil = 0 if oil<0.5
replace opu = 1 if opu>=0.5
replace opu = 0 if opu<0.5

*label variables
label var bedrms "bedrooms"
label var halfb "half baths"
label var baths "bathrooms"
label var nunits "units in building"
label var degree "degree day scale"
label var dry "clothes dryer"
label var dish "dishwasher"
label var built_middle "decade built"
label var air "room air"
label var airsys "central air"
label var mod "moderate conditions"
label var sev "bad conditions"
label var inc_real "real income"
label var rooms "rooms"
label var metro3 "urbanization scale"

eststo tpay_oil: quietly estpost summarize bedrms rooms halfb baths nunits degree dry dish built_middle air airsys mod sev inc_real if opu==0&oil==1 
eststo tpay_gas: quietly estpost summarize bedrms rooms halfb baths nunits degree dry dish built_middle air airsys mod sev inc_real if opu==0&oil==0 
eststo lpay_oil: quietly estpost summarize bedrms rooms halfb baths nunits degree dry dish built_middle air airsys mod sev inc_real if opu==1&oil==1 
eststo lpay_gas: quietly estpost summarize bedrms rooms halfb baths nunits degree dry dish built_middle air airsys mod sev inc_real if opu==1&oil==0

esttab tpay_oil tpay_gas lpay_oil lpay_gas using tab1.tex, title(Covariate Comparison Between Fuel Type and Payment Regime Combinations) cells(mean(pattern(1 1 1 1) label(none) fmt(3)) se(pattern(1 1 1 1) label(" ") par fmt(3))) mtitles("tenant pay oil" "tenant pay gas" "landlord pay oil" "landlord pay gas") ///
replace label nonumbers alignment(cccc) gaps width(\hsize)
