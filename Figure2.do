*SET PATH HERE TO THE "Fuel Price +CPI Data" FOLDER
global dirpath "C:\Users\ecmyers\Dropbox\AHS\Replication\Fuel Price +CPI Data"

*SET PATH WHERE YOU WANT TO SAVE FIGURE 2 HERE
cd "C:\Users\ecmyers\Dropbox\AHS\Replication\Figures"

*********************************************************************************************************************************************************************************
*FIGURE 2:
*********************************************************************************************************************************************************************************

use "$dirpath\ng_price_reg", clear
merge 1:1 survey_year using "$dirpath\oil_price_reg", keep(match) nogenerate

twoway (scatter real_ng_reg survey_year, c(L) lcolor(blue) mcolor(blue) sort(survey_year)) ///
(scatter real_oil_reg survey_year, c(L) lcolor(red) mcolor(red) lpattern(dash) msymbol(triangle) sort(survey_year)), ///
title(Real Heating Prices per MMBTU:) subtitle(2014 dollars) xtitle(Year) ytitle("$/MMBtu") legend(label(1 "Natural Gas")label(2 "Heating Oil")) scheme(s1color)
graph export fig2.png, as(png) replace

