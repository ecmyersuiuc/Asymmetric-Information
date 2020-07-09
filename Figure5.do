*SET PATH HERE TO THE "Clean Data" FOLDER
global dirpath "C:\Users\ecmyers\Dropbox\AHS\Replication\Clean Data"

*SET PATH WHERE YOU WANT TO SAVE FIGURE 5 HERE
cd "C:\Users\ecmyers\Dropbox\AHS\Replication\Figures"

*********************************************************************************************************************************************************************************
*FIGURE 5:
*********************************************************************************************************************************************************************************

use "$dirpath\switch_oil", clear

collapse switch2gas diff_avg_real, by(lag_opu survey_year)
drop if lag_opu==.
sort survey_year lag_opu
bysort survey_year: gen s2g_diff = switch2gas-switch2gas[_n-1]

twoway (scatter diff_avg_real survey_year, c(L) lcolor(navy) mcolor(navy) sort(survey_year) ytitle("$/MMBtu",axis(1) suffix)) ///
(scatter s2g_diff survey_year, c(L) lcolor(gray) mcolor(gray) lpattern(dash) msymbol(square) sort(survey_year) yaxis(2) ytitle("difference in probability", axis(2))), ///
title(Difference in Probability of Switching) subtitle(landlord-pay - tenant-pay) ytitle("$/MMBtu") xtitle(Year) legend(label(1 "price difference") label(2 "landlord pay-tenant pay") ) scheme(s1color)
graph export fig5.pdf, as(pdf) replace


