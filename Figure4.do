*SET PATH HERE TO THE "Clean Data" FOLDER
global dirpath "C:\Users\ecmyers\Dropbox\AHS\Replication\Clean Data"

*SET PATH WHERE YOU WANT TO SAVE FIGURE 4 HERE
cd "C:\Users\ecmyers\Dropbox\AHS\Replication\Figures"

*********************************************************************************************************************************************************************************
*FIGURE 4:
*********************************************************************************************************************************************************************************

use "$dirpath\renter_full", clear

collapse rent_real reg_diff_real, by (survey_year oil opu)
sort survey opu oil
bysort survey: gen tpu_diff = rent_real[_n+1]-rent_real if _n==1
bysort survey: replace tpu_diff = tpu_diff[_n-1] if tpu_diff==.
bysort survey: gen opu_diff = rent_real[_n+1]-rent_real if _n==3
sort survey opu_diff
bysort survey: replace opu_diff = opu_diff[_n-1] if opu_diff==.
replace tpu_diff = -tpu_diff

twoway (scatter reg_diff_real survey_year, c(L) lcolor(navy) mcolor(navy) sort(survey_year) ytitle("$/MMBtu",axis(1) suffix)) ///
||(scatter opu_diff survey_year, c(L) lcolor(gray) mcolor(gray) lpattern(dash) msymbol(square) sort(survey_year) yaxis(2) ytitle("mean rent difference",axis(2)) ylabel(-25(25)125, axis(2))), ///
title(Landlord Pays Energy) ytitle("$/MMBtu") xtitle(Year) legend(label(1 "price diff")label(2 "mean oil rent-mean gas rent")) name(opu, replace) scheme(s1color)

twoway (scatter reg_diff_real survey_year, c(L) lcolor(navy) mcolor(navy) sort(survey_year) ytitle("$/MMBtu",axis(1) suffix)) ///
(scatter tpu_diff survey_year, c(L) lcolor(gray) mcolor(gray) lpattern(dash) msymbol(square) sort(survey_year) yaxis(2) ytitle("mean rent difference",axis(2)) ylabel(-95(25)55, axis(2))), ///
title(Tenant Pays Energy) ytitle("$/MMBtu") xtitle(Year) legend(label(1 "price diff")label(2 "mean gas rent-mean oil rent")) name(tpu, replace) scheme(s1color)

graph combine opu tpu, iscale(1.2) xsize(12) ysize(4) graphregion(margin(zero)) scheme(s1color)
graph export fig4.pdf, as(pdf) replace



