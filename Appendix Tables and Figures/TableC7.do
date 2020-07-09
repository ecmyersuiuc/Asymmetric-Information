*SET PATH HERE TO THE "Clean Data" FOLDER
global dirpath "C:\Users\ecmyers\Dropbox\AHS\Replication\Clean Data"

*SET PATH WHERE YOU WANT TO SAVE TABLE C7 HERE
cd "C:\Users\ecmyers\Dropbox\AHS\Replication\Tables"

*********************************************************************************************************************************************************************************
*TABLE C7:
*********************************************************************************************************************************************************************************

use "$dirpath\switch_oil", clear
eststo clear
label variable lag_opuxavg_wt_futures_diff "Landlord-Pay Indicator $\times$ (Price$^{\text{oil}}$-Price$^{\text{gas}}$)"
label variable lag_opu "Landlord-Pay Indicator"

eststo: reg switch2gas i.built_bin#i.survey lag_opu lag_opuxavg_wt_futures_diff  if panel>=4, vce(cluster control)
estadd local fixed1 "Yes", replace
estadd local fixed2 "No", replace
estadd local fixed3 "No", replace
eststo: reg switch2gas lag_opu lag_opuxavg_wt_futures_diff i.bedrms i.baths i.halfb i.rooms i.metro3 i.degree nunits dry dish air airsys mod sev i.inc_bin i.built_bin#i.survey if panel>=4, vce(cluster control)
estadd local fixed1 "Yes", replace
estadd local fixed2 "Yes", replace
estadd local fixed3 "No", replace
eststo: reghdfe switch2gas lag_opu lag_opuxavg_wt_futures_diff if panel>=4, absorb(dry dish air airsys mod sev i.inc_bin#i.survey i.bedrms#i.survey i.baths#i.survey i.halfb#i.survey i.rooms#i.survey c.nunits#i.survey i.degree#i.survey i.metro3#i.survey) vce(cluster control)
estadd local fixed1 "Yes", replace
estadd local fixed2 "Yes", replace
estadd local fixed3 "Yes", replace

esttab using tabC7.tex, replace label booktabs obslast star(* 0.1 ** 0.05 *** 0.01) nodep nonumbers nomtitles se keep(lag_opuxavg_wt_futures_diff lag_opu) order(lag_opuxavg_wt_futures_diff lag_opu) ///
alignment(D{.}{.}{-1}) width(1.0\hsize)  nonotes prehead("\begin{table}[htbp]" "\begin{center}" "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" "\caption{@title}" "\label{switch:avgfutures}" "\begin{tabular*}{1.0\hsize}{@{\hskip\tabcolsep\extracolsep\fill}lccc{D{.}{.}{-1}}}" "\toprule" "& Conversion & Conversion & Conversion  \\" "& Indicator & Indicator & Indicator  \\") ///
postfoot("\bottomrule" "\end{tabular*}" "\end{center}" "\par \noindent \footnotesize {Notes: The sample is limited to those observed 4+ times, which is about 38\% of the units in the sample (1047 units, 5177 observations). The sample only includes oil homes that have either switched fuel types once or never. Once a unit switches to gas, subsequent observations are removed for that unit.  The unit of observation is apartment unit by year.  Price$^{\text{oil}}$ is the mean futures price for home heating oil (dollars per MMBTU) for survey year \emph{t} and \emph{t-1}, Price$^{\text{gas}}$ the mean futures price of natural gas (dollars per MMBTU) for survey year \emph{t} and \emph{t-1}.  Mean futures prices are calculated by weighting all traded futures prices for the year of the survey and the year before by the discount factor with a 4 percent discount rate.  All prices are inflated to 2014 dollars.  All specifications include decade built indicator by year indicator flexible trends.  Standard errors are in parentheses and clustered at unit level.  ***, ** and * denote statistical significance at the 1, 5 and 10 percent levels.}" "\end{table}") ///
title(Estimation of the Effect of 2 Year Average Relative Future Heating Price Difference on the Probability of Converting From Oil to Gas) s(fixed1 fixed2 fixed3 N, label("Decade Built Indicator $\times$ Year Indicator" "Covariates"  "Covariate Indicators $\times$ Year Indicator")) 




