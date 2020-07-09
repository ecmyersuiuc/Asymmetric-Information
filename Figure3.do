*SET PATH HERE TO THE "Clean Data" FOLDER
global dirpath "C:\Users\ecmyers\Dropbox\AHS\Replication\Clean Data"

*SET PATH WHERE YOU WANT TO SAVE FIGURE 3 HERE
cd "C:\Users\ecmyers\Dropbox\AHS\Replication\Figures"

*********************************************************************************************************************************************************************************
*FIGURE 3:
*********************************************************************************************************************************************************************************

use "$dirpath\turnover_full", clear

collapse turnover diff_avg_real, by (survey_year oil opu)
sort survey opu oil
bysort survey: gen tpu_diff = turnover[_n+1]-turnover if _n==1
bysort survey: replace tpu_diff = tpu_diff[_n-1] if tpu_diff==.
bysort survey: gen opu_diff = turnover[_n+1]-turnover if _n==3
sort survey opu_diff
bysort survey: replace opu_diff = opu_diff[_n-1] if opu_diff==.
gen trip_diff = tpu_diff-opu_diff

twoway (scatter diff_avg_real survey_year, c(L) lcolor(navy) mcolor(navy) sort(survey_year) ytitle("$/MMBtu",axis(1))) ///
(scatter trip_diff survey_year, c(L) lcolor(gray) mcolor(gray) lpattern(dash) msymbol(square) sort(survey_year) yaxis(2) ytitle("difference-in-differences of means", axis(2))), ///
title(Difference-in-Differences in Mean Turnover of Tenancy) subtitle( (tenant pay oil - tenant pay gas)-(landlord pay oil - landlord pay gas) ) ytitle("$/MMBtu") xtitle(Year) legend(label(1 "price difference")label(2 "difference-in-differences")) scheme(s1color)
graph export fig3.png, as(png) replace



