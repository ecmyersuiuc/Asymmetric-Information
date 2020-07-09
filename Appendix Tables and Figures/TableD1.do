*SET PATH HERE TO THE "Clean Data" FOLDER
global dirpath "C:\Users\ecmyers\Dropbox\AHS\Replication\Clean Data"

*SET PATH WHERE YOU WANT TO SAVE TABLE D1 HERE
cd "C:\Users\ecmyers\Dropbox\AHS\Replication\Tables"

*********************************************************************************************************************************************************************************
*TABLE D1:
*********************************************************************************************************************************************************************************

use "$dirpath\switch_oil", clear
eststo clear
label var switch2gas "Convert to Gas"

foreach x in baths_raw bedrms_raw halfb_raw rooms_raw airsys air mod sev dry dish  {

	eststo: reghdfe `x' switch2gas if panel>=4, absorb(control) vce(cluster control)
}

esttab using tabD1.tex, replace label booktabs obslast nostar nodep nonumbers nomtitles p keep(switch2gas) order(switch2gas) ///
 alignment(D{.}{.}{-1}) width(1.0\hsize)  nonotes prehead("\begin{table}[htbp]" "\begin{center}" "\footnotesize" "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" "\caption{@title}" "\label{switch:observables}" "\begin{tabular*}{1.0\hsize}{@{\hskip\tabcolsep\extracolsep\fill}lcccccccccc{D{.}{.}{-1}}}" "\toprule" "& Number & Number & Number & Number & Central & Room & Moderate & Severe & Clothes & Dish \\" "& Bathrooms & Bedrooms & Half Bath & Rooms & Air  & Air & Conditions & Conditions & Dryer & Washer \\") ///
 postfoot("\bottomrule" "\end{tabular*}" "\end{center}" "\par \noindent \footnotesize {Notes: The sample used is the same as for the conversion from oil to gas analysis in the main paper. The sample is limited to those observed 4+ times, which is about 38\% of the units in the sample (1047 units, 5177 observations). The sample only includes oil homes that have either switched fuel types once or never. Once a unit switches to gas, subsequent observations are removed for that unit.  The unit of observation is apartment unit by year.  The Simes (1986) procedure is used to perform false discovery rate (FDR) corrections to the p-values.}" "\end{table}") ///
 title(Within Unit Correlation: Unit Characteristics and Conversion from Oil to Gas) s(N) 

*Q-values added "by hand" to the table using the following
 global tflist ""
 global modseq=0
 foreach X of var baths_raw bedrms_raw halfb_raw rooms_raw airsys air mod sev dry dish {
 global modseq=$modseq+1
 tempfile tfcur
 parmby "reghdfe `X' switch2gas if panel>=4, absorb(control) vce(cluster control)", label command format(estimate min95 max95 %8.2f p %8.1e) idn($modseq) saving(`"`tfcur'"',replace) flist(tflist)
 }
 drop _all
 append using $tflist

qqvalue p, method(simes) qvalue(qval) 
save qval, replace



