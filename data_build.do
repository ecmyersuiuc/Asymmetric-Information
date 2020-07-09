**This is a .do file combines AHS data with fuel price data and creates variables used in the analysis

********************************************************************************************************************************
*STEP 1: Get a clean dependent variable for rent
*Keep units in the northeast census region
*Keep only those units that are rented (drop owned and occupied without payment of rent and not applicable)
*If a rent amount is filled in and tenure is missing, change it to rented
*Keep only those units that pay rent on a monthly basis
*Drop those that have a rent adjustment for relationship with owner
*Drop those whose rent is limited by rent control/stabilization
*Drop if they received a voucher to help pay rent
*Drop if not suitable for year-round use
*Drop if rent==1 ==> rent depends on the income of occupants such as public housing
*Drop top and bottom 1% of rent values for each survey year 
********************************************************************************************************************************

clear
set more off

*set path to location of "Raw Data" and "Fuel Price+CPI Data" folders here
global dirpath "C:\Users\ecmyers\Dropbox\AHS\Replication"
cd "$dirpath\Clean Data"

use "$dirpath\Raw Data\ahs_full", clear
format control %15.0f

keep if region==1
count
unique(control)
bysort control: egen count = count(survey_year)
tab count
drop count

replace rent = . if rent==-6
keep if rent~=.
count
unique(control)

replace tenure = 2 if tenure==-6|tenure==.
tab tenure
keep if tenure==2

tab frent
keep if frent==12

drop if rntadj==1
drop if rcntrl==1
drop if yrrnd==2
drop if rent==1
replace istatus=istatu if istatus==.


count 
gen extreme = 0
foreach x in 1985 1987 1989 1991 1993 1995 1997 1999 2001 2003 2005 2007 2009 2011 {
	centile rent if survey_year==`x', centile(1 99)
	gen rent_1pct = r(c_1)
	gen rent_99pct = r(c_2)
	replace extreme = 1 if rent<=rent_1pct&survey_year==`x'
	replace extreme = 1 if rent>=rent_99pct&survey_year==`x'
	drop rent_1pct rent_99pct
}

replace unitsf = . if unitsf<100
replace nunits = . if nunits<0

save renter_full, replace

********************************************************************************************************************************
*STEP 2:
*Create indicator variables for oil and gas and one for all other fuels
*Create indicator variables for owner pay utilities (opu) and tenant pay utilities (tpu)
*Drop observations if they heat with oil and supplement with gas or vice versa
********************************************************************************************************************************

gen oil = hfuel==3
gen gas = hfuel==2
gen other = oil==0&gas==0

drop if (oil==1&sgas==1)|(gas==1&soil==1)

gen opg = buyg==2
gen opo = buyo==2

gen tpg = (buyg==-6|buyg==.)&amtg~=.&amtg~=-6&amtg~=0
gen tpo = (buyo==-6|buyo==.)&amto~=.&amto~=-6&amto~=0

gen opu = oil*opo+gas*opg
gen tpu = oil*tpo+gas*tpg

sort control survey_year
gen lag_opu=.
bysort control: replace lag_opu = opu[_n-1] if _n~=1

********************************************************************************************************************************
*STEP 3 Metro variable: The metro variable was used before 1997 and metro3 after 1997
*I fill in the metro3 variable for the earlier survey years using the following 
*metro			metro3
*1				1
*2,3			2
*4				3
*5,6			4
*7				5
********************************************************************************************************************************

replace metro3=1 if metro==1
replace metro3=2 if metro==2|metro==3
replace metro3=3 if metro==4
replace metro3=4 if metro==5|metro==6
replace metro3=5 if metro==7

********************************************************************************************************************************
*STEP 4: Year built variable
*From the codebooks, I was able to figure out the conversion between the 1985-1995 format and 1997 onward format
*					1985-1995			1997+

*1919 or earlier	9					1919
*1920-1929			8					1920
*1930-1939			7					1930
*1940-1949			6					1940
*1950-1959			5					1950
*1960-1969			4					1960
*1970-1974			3					1970
*1975-1979			1,2					1975
*1980-1984			YY					1980
*1985-1989			YY					1985
*1990-2000			YY					YYYY
********************************************************************************************************************************
*First convert from YYYY format to YY format

forval x=80/95 {
	replace built = 1900+`x' if built==`x' 
}

*Next convert 1-9 to year formats
replace built = 1975 if built==1|built==2
replace built = 1970 if built==3
replace built = 1960 if built==4
replace built = 1950 if built==5
replace built = 1940 if built==6
replace built = 1930 if built==7
replace built = 1920 if built==8
replace built = 1919 if built==9

*Convert year built in the 1980s to more modern coding scheme
replace built = 1980 if built>1980&built<1985
replace built = 1985 if built>1985&built<1990

*Create bins for later built years
gen built_bin = built
replace built_bin = 1990 if built>1989&built<1995
replace built_bin = 1995 if built>1994&built<2000
replace built_bin = 2000 if built>1999
replace built_bin = 2005 if built>2004

*Create a variable for the middle of each bin for putting built in as a level control
gen built_middle = built
replace built_middle = built+2 if built>1970&built<1990
replace built_middle = built+4.5 if built<1970&built>1919

save renter_full, replace

********************************************************************************************************************************
*Create a new tenant variable from SAMEHH
*First bring in the correction for 1997
*http://www.huduser.org/portal/node/1915
********************************************************************************************************************************

insheet using "$dirpath\Raw Data\AHS_1997_SAMEHH_fix\tpuf97_samehh.txt", clear names
destring(control r_samehh), ignore(') replace
format control %15.0f
gen survey_year=1997

merge 1:1 control survey using renter_full
replace samehh = r_samehh if _merge==3
drop if _merge==1
drop _merge r_samehh
gen new_tenant = samehh==2

********************************************************************************************************************************
*Clean up measurement error in the covariates 
*Replace other entries with the most commonly observed value (these should not change over time)
*Take the average of most common if there is a tie
********************************************************************************************************************************

foreach x in built_bin rooms baths halfb metro3 bedrms degree unitsf built_middle nunits {
	bysort control `x': egen count_`x' = count(survey_year)
	replace count_`x' =0 if `x'==.
	bysort control: egen temp1 = max(count_`x')
	gen temp2 = `x' if count_`x'==temp1
	bysort control: egen temp3 = mean(temp2)
	if `x'==built_bin {
		replace temp3 = round(temp3,10) if temp3<1970&temp3>1919
		replace temp3 = round(temp3,5) if temp3>=1970
	}
		
	else {
		replace temp3 = round(temp3,1)
	}
	order control survey `x' count_`x' temp*
	gen `x'_raw = `x'
	replace `x' = temp3
	drop temp*
}

drop count*

*cap rooms, baths and halfb at top of recs
replace rooms = 10 if rooms>10
replace baths = 4 if baths>4
replace halfb = 2 if halfb>2
save renter_full, replace

***********************************************************************************************************************
*Create a regional price variable for natural gas and oil
***********************************************************************************************************************

*Bring in state-level NG price .csv file
insheet using "$dirpath\Fuel Price +CPI Data\state_gas_price.csv", clear names
ren sourcekey year
global state me nh vt ny ma ct ri pa nj
drop if _n==1

foreach s in $state {
	ren n3010`s'3 price`s'
	destring(price`s'), replace
}

drop n3*
destring (year), replace
keep if year>1982&year<=2009

reshape long price, i(year) j(state) string

save "$dirpath\Fuel Price +CPI Data\ng_price_reg", replace

*Bring in NG consumption .csv file
insheet using "$dirpath\Fuel Price +CPI Data\state_gas_cons.csv", clear names
ren sourcekey year
global state me nh vt ny ma ct ri pa nj
drop if _n==1

foreach s in $state {
	ren n3010`s'2 cons`s'
	destring(cons`s'), replace
}

drop n3*
destring (year), replace
keep if year>1982&year<=2009

reshape long cons, i(year) j(state) string

merge 1:1 state year using "$dirpath\Fuel Price +CPI Data\ng_price_reg", keep(match) nogenerate

*Create a consumption-weighted average natural gas price
bysort state: egen st_total = sum(cons)
egen total = sum(cons)
gen weight = st_total/total
gen pr_weight = weight*price
bysort year: egen reg_ng_price = sum(pr_weight)
keep year reg_ng_price
duplicates drop
tsset year
gen lag_ng_reg_2yr = l2.reg_ng_price
gen lag_ng_reg_1yr = l.reg_ng_price

merge m:1 year using "$dirpath\Fuel Price +CPI Data\cpi", keep(match) nogenerate

*Convert natural gas price into $/MMBTU
replace reg_ng_price = reg_ng_price/1.023
replace lag_ng_reg_2yr = lag_ng_reg_2yr/1.023
replace lag_ng_reg_1yr = lag_ng_reg_1yr/1.023

*Adjust for 82% efficiency of average natural gas furnace
replace reg_ng_price = reg_ng_price/0.82
replace lag_ng_reg_2yr = lag_ng_reg_2yr/0.82
replace lag_ng_reg_1yr = lag_ng_reg_1yr/0.82

*Inflate price into real 2014 prices (base CPI = 2.386 for October 2014)
sort year
gen real_ng_reg = (2.386/cpi)*reg_ng_price
gen lag_real_ng_reg_2yr = (2.386/cpi[_n-2])*lag_ng_reg_2yr
gen lag_real_ng_reg_1yr = (2.386/cpi[_n-1])*lag_ng_reg_1yr

keep if year>1984
ren year survey_year
save "$dirpath\Fuel Price +CPI Data\ng_price_reg", replace

*merge with AHS data
merge 1:m survey_year using renter_full, keep (match) nogenerate
save renter_full, replace

*Bring in Oil price .csv file
insheet using "$dirpath\Fuel Price +CPI Data\state_oil_price.csv", clear 
ren date year
global state maine newhampshire vermont newyork massachusetts connecticut rhodeisland pennsylvania newjersey
drop if _n==1

foreach s in $state {
	ren `s'no2distillateresid price`s'
	destring(price`s'), replace
}

keep year price*
destring (year), replace
keep if year>1982
drop if year==2011
reshape long price, i(year) j(state) string

save "$dirpath\Fuel Price +CPI Data\oil_price_reg", replace

*Bring in Oil consumption .csv file
insheet using "$dirpath\Fuel Price +CPI Data\state_oil_cons.csv", clear names
ren date year
drop if _n==1

foreach s in $state {
	ren `s'totaldistillate cons`s'
	destring(cons`s'), replace
}

keep year cons*
destring (year), replace
keep if year>1982&year<=2009

reshape long cons, i(year) j(state) string

merge 1:1 state year using "$dirpath\Fuel Price +CPI Data\oil_price_reg", keep(match) nogenerate

*Create a consumption-weighted average oil price
bysort state: egen st_total = sum(cons)
egen total = sum(cons)
gen weight = st_total/total
gen pr_weight = weight*price
bysort year: egen reg_oil_price = sum(pr_weight)

keep year reg_oil_price
duplicates drop
tsset year
gen lag_oil_reg_2yr = l2.reg_oil_price
gen lag_oil_reg_1yr = l.reg_oil_price

merge m:1 year using "$dirpath\Fuel Price +CPI Data\cpi", keep(match) nogenerate

*Convert oil price into $/MMBTU
replace reg_oil_price = reg_oil_price/.13869
replace lag_oil_reg_2yr = lag_oil_reg_2yr/.13869
replace lag_oil_reg_1yr = lag_oil_reg_1yr/.13869

*Adjust for 78% efficiency of average heating oil furnace
replace reg_oil_price = reg_oil_price/0.78
replace lag_oil_reg_2yr = lag_oil_reg_2yr/0.78
replace lag_oil_reg_1yr = lag_oil_reg_1yr/0.78


*Inflate price into real 2014 prices (base CPI = 2.386 for October 2014)
gen real_oil_reg = (2.386/cpi)*reg_oil_price
sort year
gen lag_real_oil_reg_2yr = (2.386/cpi[_n-2])*lag_oil_reg_2yr
gen lag_real_oil_reg_1yr = (2.386/cpi[_n-2])*lag_oil_reg_1yr

drop cpi
keep if year>1984
ren year survey_year
save "$dirpath\Fuel Price +CPI Data\oil_price_reg", replace

*merge with AHS data
merge 1:m survey_year using renter_full, keep (match) nogenerate
save renter_full, replace

***********************************************************************************************************************
*Create a monthly regional price variable for robustness to July t-1 to June t in Online Appendix
***********************************************************************************************************************

*Bring in NG monthly price .csv file
insheet using "$dirpath\Fuel Price +CPI Data\state_gas_price_monthly.csv", clear names
ren sourcekey month_of_sample
global state me nh vt ny ma ct ri pa nj

foreach s in $state {
	ren n3010`s'3 price`s'
}

drop n3*

gen year = "1988"
forval y = 89/99 {
	replace year = "19`y'" if strmatch(month_of_sample,"*`y'*")==1
}

replace year = "2000" if strmatch(month_of_sample,"*00*")==1

forval y = 1/9 {
	replace year = "200`y'" if strmatch(month_of_sample,"`y'-*")==1
}

drop if year=="1988"

gen month = 12
replace month = 1 if strmatch(month_of_sample,"*Jan*")==1
replace month = 2 if strmatch(month_of_sample,"*Feb*")==1
replace month = 3 if strmatch(month_of_sample,"*Mar*")==1
replace month = 4 if strmatch(month_of_sample,"*Apr*")==1
replace month = 5 if strmatch(month_of_sample,"*May*")==1
replace month = 6 if strmatch(month_of_sample,"*Jun*")==1
replace month = 7 if strmatch(month_of_sample,"*Jul*")==1
replace month = 8 if strmatch(month_of_sample,"*Aug*")==1
replace month = 9 if strmatch(month_of_sample,"*Sep*")==1
replace month = 10 if strmatch(month_of_sample,"*Oct*")==1
replace month = 11 if strmatch(month_of_sample,"*Nov*")==1


reshape long price, i(year month) j(state) string
destring(year), replace
drop month_of_sample
sort state year month

save "$dirpath\Fuel Price +CPI Data\ng_price_reg_jul_jun", replace

*Bring in NG monthly consumption .csv file
insheet using "$dirpath\Fuel Price +CPI Data\state_gas_cons_monthly.csv", clear names
ren sourcekey month_of_sample
global state me nh vt ny ma ct ri pa nj

foreach s in $state {
	ren n3010`s'2 cons`s'
}

drop n3*

gen year = "1988"
forval y = 1989/2009 {
	replace year = "`y'" if strmatch(month_of_sample,"*`y'*")==1
}

drop if year=="1988"

gen month = 12
replace month = 1 if strmatch(month_of_sample,"*Jan*")==1
replace month = 2 if strmatch(month_of_sample,"*Feb*")==1
replace month = 3 if strmatch(month_of_sample,"*Mar*")==1
replace month = 4 if strmatch(month_of_sample,"*Apr*")==1
replace month = 5 if strmatch(month_of_sample,"*May*")==1
replace month = 6 if strmatch(month_of_sample,"*Jun*")==1
replace month = 7 if strmatch(month_of_sample,"*Jul*")==1
replace month = 8 if strmatch(month_of_sample,"*Aug*")==1
replace month = 9 if strmatch(month_of_sample,"*Sep*")==1
replace month = 10 if strmatch(month_of_sample,"*Oct*")==1
replace month = 11 if strmatch(month_of_sample,"*Nov*")==1

reshape long cons, i(year month) j(state) string
drop month_of_sample
destring(year), replace
gen year_jul_jun = year
replace year_jul_jun = year+1 if month>=7
bysort year_jul_jun: egen year_total = sum(cons)
gen state_month_wt = cons/year_total

merge 1:1 state year month using "$dirpath\Fuel Price +CPI Data\ng_price_reg_jul_jun", nogenerate
merge m:1 year using "$dirpath\Fuel Price +CPI Data\cpi", keep(match) nogenerate

*Put natural gas monthly regional prices into $/mmbtu
replace price = price/1.023

*adjust gas monthly prices by furnace efficiency
replace price = price/0.82

*Make the prices "real" before taking the weighted average
gen real_price = (2.386/cpi)*price

*Take the weighted average over the jul - jun year
bysort year_jul_jun: egen real_ng_jul_jun = sum(state_month_wt*real_price)

keep year_jul_jun real_ng_jul_jun
duplicates drop
ren year_jul_jun survey_year
replace real_ng_jul_jun = . if survey_year==1989
sort survey_year
gen lag_real_ng_jul_jun = real_ng_jul_jun[_n-1]
egen avg_jul_jun_gas = rowmean(lag_real_ng_jul_jun real_ng_jul_jun)
replace avg_jul_jun_gas = . if lag_real_ng_jul_jun==.
save "$dirpath\Fuel Price +CPI Data\ng_price_reg_jul_jun", replace

*merge with AHS data
merge 1:m survey_year using renter_full, keep (using match) nogenerate

save renter_full, replace

*Bring in oil monthly price .csv file
insheet using "$dirpath\Fuel Price +CPI Data\state_oil_price_monthly.csv", clear names
ren sourcekey month_of_sample
global state me nh vt ny ma ct ri pa nj

foreach s in $state {
	ren ema_epd2_prt_s`s'_dpg price`s'
}

drop ema* v35

gen year = "1988"
forval y = 1989/2009 {
	replace year = "`y'" if strmatch(month_of_sample,"*`y'*")==1
}


drop if year=="1988"

gen month = 12
replace month = 1 if strmatch(month_of_sample,"*Jan*")==1
replace month = 2 if strmatch(month_of_sample,"*Feb*")==1
replace month = 3 if strmatch(month_of_sample,"*Mar*")==1
replace month = 4 if strmatch(month_of_sample,"*Apr*")==1
replace month = 5 if strmatch(month_of_sample,"*May*")==1
replace month = 6 if strmatch(month_of_sample,"*Jun*")==1
replace month = 7 if strmatch(month_of_sample,"*Jul*")==1
replace month = 8 if strmatch(month_of_sample,"*Aug*")==1
replace month = 9 if strmatch(month_of_sample,"*Sep*")==1
replace month = 10 if strmatch(month_of_sample,"*Oct*")==1
replace month = 11 if strmatch(month_of_sample,"*Nov*")==1


reshape long price, i(year month) j(state) string
destring(year), replace
drop month_of_sample
sort state year month

save "$dirpath\Fuel Price +CPI Data\oil_price_reg_jul_jun", replace


*Bring in oil monthly consumption .csv file
insheet using "$dirpath\Fuel Price +CPI Data\state_oil_cons_monthly.csv", clear names
ren date month_of_sample
global state maine newhampshire vermont newyork massachusetts connecticut rhodeisland pennsylvania newjersey

foreach s in $state {
	ren `s'no2fueloil cons`s'
}

keep month_of_sample cons*

gen year = "1988"
forval y = 1989/2009 {
	replace year = "`y'" if strmatch(month_of_sample,"*`y'*")==1
}

drop if year=="1988"

gen month = 12
replace month = 1 if strmatch(month_of_sample,"*Jan*")==1
replace month = 2 if strmatch(month_of_sample,"*Feb*")==1
replace month = 3 if strmatch(month_of_sample,"*Mar*")==1
replace month = 4 if strmatch(month_of_sample,"*Apr*")==1
replace month = 5 if strmatch(month_of_sample,"*May*")==1
replace month = 6 if strmatch(month_of_sample,"*Jun*")==1
replace month = 7 if strmatch(month_of_sample,"*Jul*")==1
replace month = 8 if strmatch(month_of_sample,"*Aug*")==1
replace month = 9 if strmatch(month_of_sample,"*Sep*")==1
replace month = 10 if strmatch(month_of_sample,"*Oct*")==1
replace month = 11 if strmatch(month_of_sample,"*Nov*")==1

reshape long cons, i(year month) j(state) string
drop month_of_sample
destring(year), replace
gen year_jul_jun = year
replace year_jul_jun = year+1 if month>=7
bysort year_jul_jun: egen year_total = sum(cons)
gen state_month_wt = cons/year_total

replace state = "me" if state=="maine"
replace state = "nh" if state=="newhampshire"
replace state = "vt" if state=="vermont"
replace state = "ny" if state=="newyork"
replace state = "ma" if state=="massachusetts"
replace state = "ct" if state=="connecticut"
replace state = "ri" if state=="rhodeisland"
replace state = "pa" if state=="pennsylvania"
replace state = "nj" if state=="newjersey"

merge 1:1 state year month using "$dirpath\Fuel Price +CPI Data\oil_price_reg_jul_jun", nogenerate
merge m:1 year using "$dirpath\Fuel Price +CPI Data\cpi", keep(match) nogenerate

*Put oil monthly regional prices into $/mmbtu
replace price = price/.13869

*adjust oil monthly prices by furnace efficiency
replace price = price/0.78

*Make the prices "real" before taking the weighted average
gen real_price = (2.386/cpi)*price

*Take the weighted average over the jul - jun year
bysort year_jul_jun: egen real_oil_jul_jun = sum(state_month_wt*real_price)

keep year_jul_jun real_oil_jul_jun
duplicates drop
ren year_jul_jun survey_year
replace real_oil_jul_jun = . if survey_year==1989
sort survey_year
gen lag_real_oil_jul_jun = real_oil_jul_jun[_n-1]
egen avg_jul_jun_oil = rowmean(lag_real_oil_jul_jun real_oil_jul_jun)
replace avg_jul_jun_oil = . if lag_real_oil_jul_jun==.
save "$dirpath\Fuel Price +CPI Data\oil_price_reg_jul_jun", replace

*merge with AHS data
merge 1:m survey_year using renter_full, keep (using match) nogenerate

save renter_full, replace

********************************************************************************************************************************
*MERGE WITH FUTURES DATA
********************************************************************************************************************************

merge m:1 survey_year using "$dirpath\Fuel Price +CPI Data\futures_price", keep(master match) nogenerate

********************************************************************************************************************************
*PUT RENT AND INCOME IN REAL TERMS
********************************************************************************************************************************

gen rent_real = (2.386/cpi)*rent
gen inc_real = (2.386/cpi)*zinc2
sum zinc2

********************************************************************************************************************************
*Put income in bins
*Define other covariates
********************************************************************************************************************************

gen inc_bin = 1 if inc_real<25000
replace inc_bin = 2 if inc_real>=25000&inc_real<50000
replace inc_bin = 3 if inc_real>=50000&inc_real<75000
replace inc_bin = 4 if inc_real>=75000&inc_real<100000
replace inc_bin = 5 if inc_real>=100000&inc_real<250000
replace inc_bin = 6 if inc_real>=250000

replace dish = 0 if dish~=1
replace dry = 0 if dry~=1
replace airsys = 0 if airsys~=1
replace air = 0 if air~=1

*zadeq = 2 moderately adequate
*zadeq = 3 severly inadequate
gen mod = zadeq==2
gen sev = zadeq==3


********************************************************************************************************************************
*Create a price difference variable for the difference between oil and ng
*Create interaction terms
********************************************************************************************************************************

egen avg_real_oil = rowmean(real_oil_reg lag_real_oil_reg_1yr)
egen avg_real_gas = rowmean(real_ng_reg lag_real_ng_reg_1yr)

gen reg_diff_real = real_oil_reg-real_ng_reg
gen diff_jul_jun_real = real_oil_jul_jun - real_ng_jul_jun
gen diff_avg_jul_jun_real = avg_jul_jun_oil - avg_jul_jun_gas
gen diff_avg_real = avg_real_oil - avg_real_gas
gen wt_futures_diff = wt_mean_oil_future - wt_mean_gas_future
*gen lag_wt_futures_diff = lag_wt_mean_oil_future - lag_wt_mean_gas_future
gen avg_wt_futures_diff = avg_wt_mean_oil_future - avg_wt_mean_gas_future

save for_switch_oil, replace

*****************************************************************************************************************************************************
*CLEAN DATA FOR TURNOVER AND RENT ANALYSIS
*****************************************************************************************************************************************************

*Define vacancy
gen vacant = istatus==3&(vacancy==1|vacancy==4)

*(80% of observations heat with oil or gas)
tab hfuel
tab other

*Heating fuel missing 29 times.  All from 1985-replace with next survey year
sort control survey
replace hfuel = hfuel[_n+1] if hfuel==.&control==control[_n+1]
replace oil = hfuel==3
replace gas = hfuel==2
replace opu = oil*opo+gas*opg
replace tpu = oil*tpo+gas*tpg

*Replace single strayers out of place
sort control survey
replace oil=oil[_n-1] if oil~=oil[_n-1]&oil~=oil[_n+1]&control==control[_n-1]&control==control[_n+1]
replace gas=gas[_n-1] if gas~=gas[_n-1]&gas~=gas[_n+1]&control==control[_n-1]&control==control[_n+1]
replace other=other[_n-1] if other~=other[_n-1]&other~=other[_n+1]&control==control[_n-1]&control==control[_n+1]
replace opu = oil*opo+gas*opg
replace tpu = oil*tpo+gas*tpg

*Fill in tenancy information for vacant units
sort control survey
replace tpu = tpu[_n-1] if vacant==1&control==control[_n-1]
replace tpu = tpu[_n+1] if vacant==1&control==control[_n+1]&control~=control[_n-1]
replace opu = opu[_n-1] if vacant==1&control==control[_n-1]
replace opu = opu[_n+1] if vacant==1&control==control[_n+1]&control~=control[_n-1]

*Drop if majority of oil and gas has no tpu or opu assigned
gen fuel = gas+oil
bysort control: egen count = sum(fuel)
tab count
gen util = opu+tpu
bysort control: egen util_count = sum(util)
gen prop_util = util_count/count
drop if prop_util<.5

*Drop if majority is other heating fuel
sort control survey
bysort control:egen total = count(survey_year)
gen ratio = count/total
drop if ratio<=.5

*Keep if fuel switches only once or less
sort control survey
bysort control: gen temp2 = control==control[_n-1]&oil~=oil[_n-1]
bysort control: egen fswitch = total(temp2)
keep if fswitch<=1
drop temp*

*Keep those we have good data for
drop if (oil==1|gas==1)&tpu==0&opu==0
keep if oil==1|gas==1

gen tpuxoil = tpu*oil

*gen price variables
gen price = real_ng_reg
replace price = real_oil_reg if oil==1
gen pricextpu = price*tpu

gen avg_price = avg_real_gas
replace avg_price = avg_real_oil if oil==1
gen avg_pricextpu = avg_price*tpu

*gen Jul-Jun price variables for robustness in Appendix
gen price_jul_jun = real_ng_jul_jun
replace price_jul_jun = real_oil_jul_jun if oil==1
gen price_jul_junxtpu = price_jul_jun*tpu

gen avg_jul_jun_price = avg_jul_jun_gas
replace avg_jul_jun_price = avg_jul_jun_oil if oil==1
gen avg_jul_jun_pricextpu = avg_jul_jun_price*tpu

*gen instrumental price variables using lag type
sort control survey
bysort control: gen lag_tpu = tpu[_n-1] if _n~=1
bysort control: gen lag_oil = oil[_n-1] if _n~=1
gen lag_tpuxoil = lag_tpu*lag_oil

gen price_lag = real_ng_reg
replace price_lag = real_oil_reg if lag_oil==1
gen pricexlag_tpu = price_lag*lag_tpu

gen price_jul_jun_lag = real_ng_jul_jun
replace price_jul_jun_lag = real_oil_jul_jun if lag_oil==1
gen price_jul_junxlag_tpu = price_jul_jun_lag*lag_tpu

gen avg_price_lag = avg_real_gas
replace avg_price_lag = avg_real_oil if lag_oil==1
gen avg_pricexlag_tpu = avg_price_lag*lag_tpu

gen avg_jul_jun_price_lag = avg_jul_jun_gas
replace avg_jul_jun_price_lag = avg_jul_jun_oil if lag_oil==1
gen avg_jul_jun_pricexlag_tpu = avg_jul_jun_price_lag*lag_tpu


save renter_full, replace

*******************************************************************************************************************************
*TURNOVER DATASET
*******************************************************************************************************************************

use renter_full, clear

*turnover variable: vacant or has a new tenant and was occupied in the last survey
sort control survey
bysort control: gen turnover = (new_tenant==1|vacant==1)&_n~=1&survey==survey[_n-1]+2&vacant[_n-1]~=1
tab turnover

*replace ineligible with missing: those ineligible to be turned over are the first observation, the last survey was missing, or the last survey was vacant
sort control survey
bysort control: replace turnover = . if _n==1|(survey~=survey[_n-1]+2)|(survey==survey[_n-1]+2&vacant[_n-1]==1)

save turnover_full, replace

*******************************************************************************************************************************
*CONVERT FROM OIL TO GAS DATASET
*******************************************************************************************************************************

use for_switch_oil, clear
drop lag_opu

*keep if a unit is defined as oil or gas and tenant pay or owner pay
drop if oil==1&(opo~=1&tpo~=1)
drop if gas==1&(opg~=1&tpg~=1)
keep if oil==1|gas==1

*create variable counting observations per unit
bysort control: egen panel = count(survey_year)

*keep only those that have switched once or never switched
sort control survey
bysort control: gen temp = control==control[_n-1]&oil~=oil[_n-1]
bysort control: egen fswitch = total(temp)
keep if fswitch<=1
drop temp

*keep only oil houses
sort control survey
bysort control: gen gas_start = gas==1&_n==1
bysort control: egen gas_starter = total(gas_start)
drop if gas_starter==1

*define conversions
sort control survey_year
gen switch2gas = gas==1&gas[_n-1]==0&control==control[_n-1]

*Post converters not eligible to convert
replace switch2gas=. if gas==1&switch2gas~=1

*only those that are not first observation are eligible to switch
sort control survey
bysort control: replace switch2gas=. if _n==1
*bysort control: replace switch2gas = . if _n==1|(survey~=survey[_n-1]+2)

bysort control: gen lag_opu = opu[_n-1] if _n~=1
gen lag_opuxreg_diff = lag_opu*reg_diff
gen lag_opuxwt_futures_diff = lag_opu*wt_futures_diff
gen lag_opuxdiff_avg_real = lag_opu*diff_avg_real
gen lag_opuxdiff_avg_jul_jun_real = lag_opu*diff_avg_jul_jun_real
gen lag_opuxavg_wt_futures_diff = lag_opu*avg_wt_futures_diff

erase for_switch_oil.dta

save switch_oil, replace


