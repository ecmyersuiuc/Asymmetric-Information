clear 

*set path to the "Raw Data" folder here
global dirpath "C:\Users\ecmyers\Dropbox\AHS\Replication\Raw Data"

********************************************************************************************************
*append the 1985-1995 data together
*keep variables of interest (data set is too big otherwise)
*create a variable for survey year
*in the 1995 dataset, the yrrnd variable is yrrn, replace yrrnd with yrrn for 1995
********************************************************************************************************

cd "$dirpath\ahs85_95"
 
global early 85 87 89 91 93 95

foreach x in $early {
	use ahs`x', clear
	gen survey_year = 19`x'
	destring (control), replace
	if `x'>85 {
		keep control status sgas soil istatu vacancy movac hequip vacvac pwt weight samedu tenure frent rntadj rcntrl yrrn* rent unitsf buy* hfuel rooms baths halfb metro bedrms region degree year survey_year built amto amtg amte mov* schpub schpri sch nunits ehigh badprp dish dry crime egreen newtrn strn badsrv air airsys shoth zadeq zinc2 condo tpark samehh billo*
	}
	if `x'==85 {
		keep control status sgas soil istatu vacancy movac hequip pwt weight tenure frent rntadj rcntrl yrrn* rent unitsf buy* hfuel rooms baths halfb metro bedrms region degree year survey_year built amto amtg amte mov* schpub schpri sch nunits ehigh badprp dish dry crime egreen newtrn strn badsrv air airsys shoth zadeq zinc2 condo tpark billo*
		save "$dirpath\ahs_full", replace
	}
	else {
		append using "$dirpath\ahs_full",
		save "$dirpath\ahs_full", replace
	}
}
 
replace yrrnd = yrrn if survey_year==1995
drop yrrn
save "$dirpath\ahs_full", replace


********************************************************************************************************
*bring in 1997-2009, keep variables of interest, and append them to the earlier data
********************************************************************************************************

use "$dirpath\ahs_data_97_09", clear 
keep control istatus status sgas soil fhoth vacancy hequip market markt movac s150mv vacvac pwt weight samedu tenure frent rntadj rcntrl yrrn* rent unitsf buy* hfuel rooms baths halfb metro3 bedrms region degree survey_year built amto amtg amte hhmove mov* lisch schpub schpri sch nunits lmed* etrans elect ehigh badprp aptch aptad dish dry crime egreen newtrn strn badsrv air airsys shoth zadeq zinc2 condo tpark samehh billo*
destring(market markt vacvac istatus status sgas soil degree buy* rcntrl rntadj yrrnd tenure sch schpub schpri ehigh badprp dish dry crime egreen newtrn strn badsrv metro zadeq airsys shoth air zinc2 samedu condo tpark samehh billo*), replace ignore(')
append using "$dirpath\ahs_full" 

save "$dirpath\ahs_full", replace
