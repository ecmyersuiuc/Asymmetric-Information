*SET PATH HERE TO THE "Clean Data" FOLDER
global dirpath "C:\Users\ecmyers\Dropbox\AHS\Replication\Clean Data"

*SET PATH WHERE YOU WANT TO SAVE TABLE 2 HERE
cd "C:\Users\ecmyers\Dropbox\AHS\Replication\Tables"

*********************************************************************************************************************************************************************************
*TABLE 2:
*********************************************************************************************************************************************************************************

use "$dirpath\turnover_full", clear
eststo clear

label variable avg_price "Heating Price"
label variable avg_pricextpu "Heating Price $\times$ Tenant-Pay Indicator" 
label variable tpuxoil "Oil Indicator $\times$ Tenant-Pay Indicator"
label variable oil "Oil Indicator"

eststo: reghdfe turnover i.bedrms i.baths i.halfb i.rooms i.metro3 i.degree nunits dry dish air airsys mod sev i.inc_bin oil tpuxoil avg_price avg_pricextpu, absorb(i.survey tpu##i.survey i.built_bin##i.survey) vce(cluster control)
estadd local fixed0A "Yes", replace
estadd local fixed0B "Yes", replace
estadd local fixed1 "Yes", replace
estadd local fixed2 "No", replace
estadd local fixed3 "No", replace

eststo: reghdfe turnover dry dish air airsys mod sev i.inc_bin oil tpuxoil avg_price avg_pricextpu, absorb(control tpu##i.survey i.built_bin##i.survey)
estadd local fixed0A "Yes", replace
estadd local fixed0B "Yes", replace
estadd local fixed1 "Yes", replace
estadd local fixed2 "Yes", replace
estadd local fixed3 "No", replace
 
eststo: reghdfe turnover dry dish air airsys mod sev i.inc_bin#i.survey i.bedrms#i.survey i.baths#i.survey i.halfb#i.survey i.rooms#i.survey c.nunits#i.survey i.degree#i.survey i.metro3#i.survey oil tpuxoil avg_price avg_pricextpu, absorb(control tpu##i.survey i.built_bin##i.survey) vce(cluster control)
estadd local fixed0A "Yes", replace
estadd local fixed0B "Yes", replace
estadd local fixed1 "Yes", replace
estadd local fixed2 "Yes", replace
estadd local fixed3 "Yes", replace

eststo: reghdfe turnover (oil tpuxoil avg_price avg_pricextpu tpu#i.survey = lag_oil lag_tpuxoil avg_price_lag avg_pricexlag_tpu lag_tpu#i.survey), absorb(control i.built_bin##i.survey dry dish air airsys mod sev i.inc_bin#i.survey i.bedrms#i.survey i.baths#i.survey i.halfb#i.survey i.rooms#i.survey c.nunits#i.survey i.degree#i.survey i.metro3#i.survey) vce(cluster control)
estadd local fixed0A "Yes", replace
estadd local fixed0B "Yes", replace
estadd local fixed1 "Yes", replace
estadd local fixed2 "Yes", replace
estadd local fixed3 "Yes", replace


esttab using tab2.tex, replace label booktabs obslast star(* 0.1 ** 0.05 *** 0.01) nodep nonumbers nomtitles se keep(avg_price avg_pricextpu tpuxoil oil) order(avg_price avg_pricextpu tpuxoil oil) ///
alignment(D{.}{.}{-1}) width(1.0\hsize) nonotes  prehead("\begin{table}[htbp]" "\begin{center}" "\footnotesize" "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" "\caption{@title}" "\label{turnover}" ///
"\begin{tabular*}{1.0\hsize}{@{\hskip\tabcolsep\extracolsep\fill}lcccc{D{.}{.}{-1}}}" "\toprule" "&&&&& \\" "Dependent Variable: Turnover Indicator & (OLS) & (OLS) & (OLS) & (2SLS) \\" "&&&& \\") /// 
postfoot("\bottomrule" "\end{tabular*}" "\end{center}" "\par \noindent \footnotesize {Notes: The unit of observation is apartment unit $\times$ year.  Heating price is the price per unit of heat (MMBTU) for home heating oil or natural gas averaged over the survey year (\emph{t}) and the previous year (\emph{t-1}) in the Northeast Census region. The price per unit heat is the retail price divided by the average furnace efficiency (0.78 for oil and 0.82 for natural gas). For the 2SLS estimations, the payment regime and fuel type from a unit's previous observation are used to instrument for its contemporaneous payment regime and fuel type. All prices are inflated to 2014 dollars.  Standard errors are in parentheses and clustered at unit level.  ***, ** and * denote statistical significance at the 1, 5 and 10 percent levels.}" "\end{table}") ///
title(Estimation of the Effect of Heating Prices on the Probability of Turning Over) s(fixed0A fixed0B fixed1 fixed2 fixed3 N, label("Covariates" "Tenant-Pay Indicator $\times$ Year FE" "Decade Built Indicator $\times$ Year Indicator" "Unit FE" "Covariate Indicator $\times$ Year Indicator"))
