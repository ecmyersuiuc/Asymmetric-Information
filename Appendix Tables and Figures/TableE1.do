*SET PATH HERE TO THE "Clean Data" FOLDER
global dirpath "C:\Users\ecmyers\Dropbox\AHS\Replication\Clean Data"

*SET PATH WHERE YOU WANT TO SAVE TABLE E1 HERE
cd "C:\Users\ecmyers\Dropbox\AHS\Replication\Tables"

*********************************************************************************************************************************************************************************
*TABLE E1:
*********************************************************************************************************************************************************************************

eststo clear
use "$dirpath\switch_oil", clear
label variable lag_opuxdiff_avg_real "Landlord-Pay Indicator $\times$ (Price$^{\text{oil}}$-Price$^{\text{gas}}$)"
label variable lag_opu "Landlord-Pay Indicator"

eststo clear

eststo: reg switch2gas lag_opu lag_opuxdiff_avg_real i.bedrms i.baths i.halfb i.rooms i.metro3 i.degree nunits dry dish air airsys mod sev i.inc_bin i.built_bin#i.survey if panel>=3, vce(cluster control)
estadd local fixed1 "Yes", replace
estadd local fixed2 "Yes", replace
eststo: reg switch2gas lag_opu lag_opuxdiff_avg_real i.bedrms i.baths i.halfb i.rooms i.metro3 i.degree nunits dry dish air airsys mod sev i.inc_bin i.built_bin#i.survey if panel>=5, vce(cluster control)
estadd local fixed1 "Yes", replace
estadd local fixed2 "Yes", replace

esttab using tabE1.tex, replace label booktabs obslast star(* 0.1 ** 0.05 *** 0.01) nodep nonumbers mtitles("(1)" "(2)" "(3)") se keep(lag_opuxdiff_avg_real lag_opu) order(lag_opuxdiff_avg_real lag_opu) ///
alignment(D{.}{.}{-1}) width(1.0\hsize)  nonotes prehead("\begin{table}[htbp]" "\begin{center}" "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" "\caption{@title}" "\label{switchrobust}" "\begin{tabular*}{1.0\hsize}{@{\hskip\tabcolsep\extracolsep\fill}lcc{D{.}{.}{-1}}}" "\toprule") ///
postfoot("\bottomrule" "\end{tabular*}" "\end{center}" "\par \noindent \footnotesize {Notes: In column 1 the sample is limited to units observed 3+ times, which is about 52\% of the units in the sample (1431 units, 5885 observations).  In column 2 the sample is limited to units observed 5+ times, which is about 31\% of the units in the sample (849 units, 4656 observations). The sample only includes oil homes that have either switched fuel types once or never.  Once a unit switches to gas, subsequent observations are removed for that unit.  The unit of observation is apartment unit $\times$ year.  Price$^{oil}$ is the average price per unit heat of home heating oil (dollars per MMBTU) for the survey year (\emph{t}) and the previous year \emph{t-1} for the Northeast Census region. Price$^{gas}$ the average price per unit heat of natural gas (dollars per MMBTU) for the survey year (\emph{t}) and the previous year \emph{t-1} for the Northeast Census region.  The price per unit heat is the retail price divided by the average furnace efficiency (0.78 for oil and 0.82 for natural gas).  All prices are inflated to 2014 dollars.  All specifications include decade built indicator by year indicator flexible trends.  Standard errors are clustered at unit level. ***, ** and * denote statistical significance at the 1, 5 and 10 percent levels.}" "\end{table}") ///
title(Estimation of the Effect of Relative Heating Prices on the Relative Probability of Converting From Oil to Gas) s(fixed1 fixed2 N, label("Covariates" "Decade Built $\times$ Year FE")) 




