*SET PATH HERE TO THE "Clean Data" FOLDER
global dirpath "C:\Users\ecmyers\Dropbox\AHS\Replication\Clean Data"

*SET PATH WHERE YOU WANT TO SAVE TABLE C4 HERE
cd "C:\Users\ecmyers\Dropbox\AHS\Replication\Tables"

*********************************************************************************************************************************************************************************
*TABLE C4:
*********************************************************************************************************************************************************************************

use "$dirpath\switch_oil", clear
eststo clear
label variable lag_opuxreg_diff "Landlord-Pay Indicator $\times$ (Price$^{\text{oil}}$-Price$^{\text{gas}}$)"
label variable lag_opu "Landlord-Pay Indicator"

eststo: reg switch2gas i.built_bin#i.survey lag_opu lag_opuxreg_diff  if panel>=4, vce(cluster control)
estadd local fixed1 "Yes", replace
estadd local fixed2 "No", replace
estadd local fixed3 "No", replace
eststo: reg switch2gas lag_opu lag_opuxreg_diff i.bedrms i.baths i.halfb i.rooms i.metro3 i.degree nunits dry dish air airsys mod sev i.inc_bin i.built_bin#i.survey if panel>=4, vce(cluster control)
estadd local fixed1 "Yes", replace
estadd local fixed2 "Yes", replace
estadd local fixed3 "No", replace
eststo: reghdfe switch2gas lag_opu lag_opuxreg_diff dry dish air airsys mod sev if panel>=4, absorb(i.inc_bin#i.survey i.bedrms#i.survey i.baths#i.survey i.halfb#i.survey i.rooms#i.survey c.nunits#i.survey i.degree#i.survey i.metro3#i.survey) vce(cluster control)
estadd local fixed1 "Yes", replace
estadd local fixed2 "Yes", replace
estadd local fixed3 "Yes", replace

esttab using tabC4.tex, replace label booktabs obslast star(* 0.1 ** 0.05 *** 0.01) nodep nonumbers nomtitles se keep(lag_opuxreg_diff lag_opu) order(lag_opuxreg_diff lag_opu) ///
 alignment(D{.}{.}{-1}) width(1.0\hsize)  nonotes prehead("\begin{table}[htbp]" "\begin{center}" "\footnotesize" "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" "\caption{@title}" "\label{switch:contemporaneous}" "\begin{tabular*}{1.0\hsize}{@{\hskip\tabcolsep\extracolsep\fill}lccc{D{.}{.}{-1}}}" "\toprule" "& Conversion& Conversion & Conversion \\" "& Indicator & Indicator & Indicator \\") ///
 postfoot("\bottomrule" "\end{tabular*}" "\end{center}" "\par \noindent \footnotesize {Notes: The sample is limited to those observed 4+ times, which is about 38\% of the units in the sample (1047 units, 5177 observations). The sample only includes oil homes that have either switched fuel types once or never. Once a unit switches to gas, subsequent observations are removed for that unit.  The unit of observation is apartment unit by year.  Price$^{\text{oil}}$ is the heating price of home heating oil (dollars per MMBTU), Price$^{\text{gas}}$ the heating price of natural gas (dollars per MMBTU) for the Northeast Census region.  The heating price is the retail price divided by the average furnace efficiency (0.78 for oil and 0.82 for natural gas).   All prices are inflated to 2014 dollars.  All specifications include decade built indicator by year indicator flexible trends.  Standard errors are in parentheses and clustered at unit level.  ***, ** and * denote statistical significance at the 1, 5 and 10 percent levels.}" "\end{table}") ///
 title(Estimation of the Effect of Contemporaneous Heating Price Differences on the Probability of Converting From Oil to Gas) s(fixed1 fixed2 fixed3 N, label("Decade Built Indicator $\times$ Year Indicator" "Covariates" "Covariate Indicators $\times$ Year Indicator")) 
