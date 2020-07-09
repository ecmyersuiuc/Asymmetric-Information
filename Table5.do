*SET PATH HERE TO THE "Clean Data" FOLDER
global dirpath "C:\Users\ecmyers\Dropbox\AHS\Replication\Clean Data"

*********************************************************************************************************************************************************************************
*Table 5: The code provide here produces the numbers used in table 5
*********************************************************************************************************************************************************************************

use "$dirpath\renter_full", clear
keep survey reg_diff_real
keep if survey>=2005
duplicates drop

gen savings = 150*2 if survey==2005
replace savings = 353*2 if survey==2007
replace savings = 283*2 if survey==2009

gen num_tpo = 546000 if survey==2005
replace num_tpo = 518000 if survey==2007
replace num_tpo = 523000 if survey==2009

gen num_should_convert = .006*reg_diff*num_tpo if survey==2005
sort survey
replace num_should_convert = .006*reg_diff*num_tpo+num_should_convert[_n-1] if _n~=1
*comes from plugging price into EPA furnace calculator
gen oil_exp = 23.20*53.2*2 if survey==2005
replace oil_exp = 27.73*53.2*2 if survey==2007
replace oil_exp = 24.96*53.2*2 if survey==2009
gen percent = savings/oil_exp
gen percent2 = (savings*num_should_convert)/(oil_exp*num_tpo)

keep survey reg_diff_real savings percent num_tpo num_should_convert percent2
order survey reg_diff_real num_tpo num_should_convert savings percent percent2




