*SET PATH HERE TO THE "Clean Data" FOLDER
global dirpath "C:\Users\ecmyers\Dropbox\AHS\Replication\Clean Data"

*SET PATH WHERE YOU WANT TO SAVE TABLE B1 HERE
global outpath "C:\Users\ecmyers\Dropbox\AHS\Replication\Tables"

*********************************************************************************************************************************************************************************
*TABLE B1:
*********************************************************************************************************************************************************************************

use "$dirpath\renter_full", clear
collapse(mean) bedrms rooms halfb baths nunits degree dry dish built_middle metro3 built_bin air airsys mod sev inc_real oil opu, by(control)

*use most common fuel type and payment regime in the unit for summary stats
replace oil = 1 if oil>=0.5
replace oil = 0 if oil<0.5
replace opu = 1 if opu>=0.5
replace opu = 0 if opu<0.5

egen group = group(oil opu)

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

iebaltab bedrms rooms halfb baths nunits degree dry dish built_middle air airsys mod sev, ///
grpvar(group) order(3 1 4 2) grplabels(3 ten-pay oil @ 1 ten-pay gas @ 4 lan-pay oil @ 2 lan-pay gas)  ///
savetex("$outpath\tabB1.tex") ///
replace onerow rowvarlabels
