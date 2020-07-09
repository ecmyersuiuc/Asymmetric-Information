*SET PATH HERE TO THE "Clean Data" FOLDER
global dirpath "C:\Users\ecmyers\Dropbox\AHS\Replication\Clean Data"

*SET PATH WHERE YOU WANT TO SAVE TABLE 3 HERE
cd "C:\Users\ecmyers\Dropbox\AHS\Replication\Tables"

*********************************************************************************************************************************************************************************
*TABLE 3:
*********************************************************************************************************************************************************************************

use "$dirpath\renter_full", clear

*Identify top and bottom 3% of rent values
drop if extreme==1
keep if survey<=2009
drop if vacant==1
eststo clear

label variable price "(1) Heating Price"
label variable pricextpu "(2) Heating Price $\times$ Tenant-Pay Indicator"  
label variable lag_tpuxoil "Lag Oil Indicator $\times$ Lag Tenant-Pay Indicator"
label variable lag_oil "Lag Oil Indicator"

*label variable price_lag "(1) Heating Price for Lag Fuel Type"
*label variable pricexlag_tpu "(2) Heating Price for Lag Fuel $\times$ Lag Tenant-Pay Ind." 
*label variable tpuxoil "Oil Indicator $\times$ Tenant-Pay Indicator"
*label variable oil "Oil Indicator"

eststo: reghdfe rent_real i.bedrms i.baths i.halfb i.rooms i.metro3 i.degree nunits dry dish air airsys mod sev i.inc_bin oil tpuxoil price pricextpu, absorb(i.survey tpu##i.survey i.built_bin##i.survey) vce(cluster control)
estadd local fixed0A "Yes", replace
estadd local fixed0B "Yes", replace
estadd local fixed0C "Yes", replace
estadd local fixed1 "No", replace
estadd local fixed2 "No", replace
estadd local fixed3 "No", replace
test price + pricextpu = 0
estadd scalar Fstat = r(F)
estadd scalar Pval = r(p)
eststo: reghdfe rent_real dry dish air airsys mod sev i.inc_bin oil tpuxoil price pricextpu, absorb(control i.survey tpu##i.survey i.built_bin##i.survey) vce(cluster control)
estadd local fixed0A "Yes", replace
estadd local fixed0B "Yes", replace
estadd local fixed0C "Yes", replace
estadd local fixed1 "Yes", replace
estadd local fixed2 "No", replace
estadd local fixed3 "No", replace
test price + pricextpu = 0
estadd scalar Fstat = r(F)
estadd scalar Pval = r(p)
eststo: reghdfe rent_real oil tpuxoil price pricextpu, absorb(control tpu##i.survey i.built_bin##i.survey dry dish air airsys mod sev i.inc_bin#i.survey i.bedrms#i.survey i.baths#i.survey i.halfb#i.survey i.rooms#i.survey c.nunits#i.survey i.degree#i.survey i.metro3#i.survey) vce(cluster control)
estadd local fixed0A "Yes", replace
estadd local fixed0B "Yes", replace
estadd local fixed0C "Yes", replace
estadd local fixed1 "Yes", replace
estadd local fixed2 "Yes", replace
estadd local fixed3 "No", replace
test price + pricextpu = 0
estadd scalar Fstat = r(F)
estadd scalar Pval = r(p)
eststo: reghdfe rent_real oil tpuxoil price pricextpu if metro3<3, absorb(control tpu##i.survey i.built_bin##i.survey dry dish air airsys mod sev i.inc_bin#i.survey i.bedrms#i.survey i.baths#i.survey i.halfb#i.survey i.rooms#i.survey c.nunits#i.survey i.degree#i.survey i.metro3#i.survey) vce(cluster control)
estadd local fixed0A "Yes", replace
estadd local fixed0B "Yes", replace
estadd local fixed0C "Yes", replace
estadd local fixed1 "Yes", replace
estadd local fixed2 "Yes", replace
estadd local fixed3 "Yes", replace
test price + pricextpu = 0
estadd scalar Fstat = r(F)
estadd scalar Pval = r(p)
eststo: reghdfe rent_real (oil tpuxoil price pricextpu tpu#i.survey =  lag_oil lag_tpuxoil price_lag pricexlag_tpu lag_tpu#i.survey), absorb(i.built_bin##i.survey control dry dish air airsys mod sev i.inc_bin#i.survey i.bedrms#i.survey i.baths#i.survey i.halfb#i.survey i.rooms#i.survey c.nunits#i.survey i.degree#i.survey i.metro3#i.survey) vce(cluster control)
estadd local fixed0A "Yes", replace
estadd local fixed0B "Yes", replace
estadd local fixed0C "Yes", replace
estadd local fixed1 "Yes", replace
estadd local fixed2 "Yes", replace
estadd local fixed3 "No", replace
test price + pricextpu = 0
estadd scalar Fstat = r(F)
estadd scalar Pval = r(p)
eststo: reghdfe rent_real (oil tpuxoil price pricextpu tpu#i.survey =  lag_oil lag_tpuxoil price_lag pricexlag_tpu lag_tpu#i.survey) if metro3<3, absorb(i.built_bin##i.survey control dry dish air airsys mod sev i.inc_bin#i.survey i.bedrms#i.survey i.baths#i.survey i.halfb#i.survey i.rooms#i.survey c.nunits#i.survey i.degree#i.survey i.metro3#i.survey) vce(cluster control)
estadd local fixed0A "Yes", replace
estadd local fixed0B "Yes", replace
estadd local fixed0C "Yes", replace
estadd local fixed1 "Yes", replace
estadd local fixed2 "Yes", replace
estadd local fixed3 "Yes", replace
test price + pricextpu = 0
estadd scalar Fstat = r(F)
estadd scalar Pval = r(p)

esttab using tab3.tex, replace label booktabs obslast star(* 0.1 ** 0.05 *** 0.01) nodep nonumbers nomtitles se keep(oil tpuxoil price pricextpu) order(price pricextpu  tpuxoil oil) ///
 alignment(D{.}{.}{-1}) width(1.0\hsize)  nonotes prehead("\begin{table}[htbp]" "\begin{center}" "\scriptsize" "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" "\caption{@title}" "\label{rent}" "\begin{tabular*}{1.0\hsize}{@{\hskip\tabcolsep\extracolsep\fill}lcccccc{D{.}{.}{-1}}}" "\toprule" ///
 "&&&&&& \\" "Dependent Variable: Monthly Rent & (OLS) & (OLS) & (OLS) & (OLS) & (2SLS) & (2SLS) \\" "&&&&&& \\") postfoot("\bottomrule" "\end{tabular*}" "\end{center}" "\par \noindent \footnotesize {Notes: The unit of observation is apartment unit-by-year.  Heating Price is the average price per unit of heat (MMBTU) from home heating oil or natural gas for the Northeast Census region.  The price per unit heat is the retail price divided by the average furnace efficiency (0.78 for oil and 0.82 for natural gas). For the 2SLS estimations, the payment regime and fuel type from a unit's previous observation are used to instrument for its contemporaneous payment regime and fuel type.  All prices are inflated to 2014 dollars.  Standard errors are in parentheses and clustered at unit level.  ***, ** and * denote statistical significance at the 1, 5 and 10 percent levels.}" "\end{table}") ///
 title(Estimation of the Effect of Heating Prices on Rent) s(Fstat Pval fixed0A fixed0B fixed0C fixed1 fixed2 fixed3 N, label("F-Statistic (1)+(2)" "2 Sided p-value" "Covariates" "Payment Regime $\times$ Year FE" "Decade Built $\times$ Year FE" "Unit FE"  "Covariate $\times$ Year FE" "Urban Only"))



