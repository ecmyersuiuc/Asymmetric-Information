*SET PATH HERE TO THE "Clean Data" FOLDER
global dirpath "C:\Users\ecmyers\Dropbox\AHS\Replication\Clean Data"

*SET PATH WHERE YOU WANT TO SAVE FIGURE B1 HERE
cd "C:\Users\ecmyers\Dropbox\AHS\Replication\Figures"

*********************************************************************************************************************************************************************************
*FIGURE B1:
*********************************************************************************************************************************************************************************

use "$dirpath\renter_full", clear
collapse(mean) bedrms rooms halfb baths nunits degree dry dish built_middle metro3 built_bin air airsys mod sev inc_real oil opu, by(control)

*use most common fuel type and payment regime in the unit for summary stats
replace oil = 1 if oil>=0.5
replace oil = 0 if oil<0.5
replace opu = 1 if opu>=0.5
replace opu = 0 if opu<0.5

*bin number of units for histogram
gen nunits_bin = 10 if nunits<=10
replace nunits_bin = 20 if nunits<=20&nunits>10
replace nunits_bin = 30 if nunits<=30&nunits>20
replace nunits_bin = 40 if nunits<=40&nunits>30
replace nunits_bin = 50 if nunits<=50&nunits>40
replace nunits_bin = 60 if nunits>50

egen group = group(oil opu)

label var bedrms "bedrooms"
label var halfb "half baths"
label var baths "bathrooms"
label var nunits_bin "units in building"
label var degree "degree day scale"
label var dry "clothes dryer"
label var dish "dishwasher"
label var built_middle "decade built"
label var air "room air"
label var airsys "central air"
label var mod "moderate conditions"
label var sev "bad conditions"
label var inc_real "real income"
label var rooms "rooms"
label var metro3 "urbanization scale"

hist rooms if opu==1&oil==1, discrete percent title("landlord pay oil") scheme(s1mono) name(room1, replace) ytitle("Percent", height(5)) xlabel(0(5)15) ylabel(0(20)40) nodraw
hist rooms if opu==1&oil==0, discrete percent title("landlord pay gas") scheme(s1mono) name(room2, replace) ytitle("Percent", height(5)) xlabel(0(5)15) ylabel(0(20)40) nodraw
hist rooms if opu==0&oil==1, discrete percent title("tenant pay oil") scheme(s1mono) name(room3, replace) ytitle("Percent", height(5)) xlabel(0(5)15) ylabel(0(20)40) nodraw
hist rooms if opu==0&oil==0, discrete percent title("tenant pay gas") scheme(s1mono) name(room4, replace) ytitle("Percent", height(5)) xlabel(0(5)15) ylabel(0(20)40) nodraw
graph combine room1 room2 room3 room4, title("Number of Rooms") scheme(s1mono) name(cov1, replace) nodraw

hist baths if opu==1&oil==1, discrete percent title("landlord pay oil") scheme(s1mono) name(bath1, replace) xlabel(0(2)8) ylabel(0(30)90) ytitle("Percent", height(5)) nodraw 
hist baths if opu==1&oil==0, discrete percent title("landlord pay gas") scheme(s1mono) name(bath2, replace) xlabel(0(2)8) ylabel(0(30)90) ytitle("Percent", height(5)) nodraw
hist baths if opu==0&oil==1, discrete percent title("tenant pay oil") scheme(s1mono) name(bath3, replace) xlabel(0(2)8) ylabel(0(30)90) ytitle("Percent", height(5)) nodraw
hist baths if opu==0&oil==0, discrete percent title("tenant pay gas") scheme(s1mono) name(bath4, replace) xlabel(0(2)8) ylabel(0(30)90) ytitle("Percent", height(5)) nodraw
graph combine bath1 bath2 bath3 bath4, title("Number of Bathrooms") scheme(s1mono) name(cov2, replace) nodraw

hist nunits_bin if opu==1&oil==1, discrete percent start(10) title("landlord pay oil") scheme(s1mono) name(nunit1, replace) xlabel(10(20)60) ylabel(0(30)90) ytitle("Percent", height(5)) nodraw
hist nunits_bin if opu==1&oil==0, discrete percent start(10) title("landlord pay gas") scheme(s1mono) name(nunit2, replace) xlabel(10(20)60) ylabel(0(30)90) ytitle("Percent", height(5)) nodraw
hist nunits_bin if opu==0&oil==1, discrete percent start(10) title("tenant pay oil") scheme(s1mono) name(nunit3, replace) xlabel(10(20)60) ylabel(0(30)90) ytitle("Percent", height(5)) nodraw
hist nunits_bin if opu==0&oil==0, discrete percent start(10) title("tenant pay gas") scheme(s1mono) name(nunit4, replace) xlabel(10(20)60) ylabel(0(30)90) ytitle("Percent", height(5)) nodraw
graph combine nunit1 nunit2 nunit3 nunit4, title("Number of Units in Building") scheme(s1mono) name(cov3, replace) nodraw

hist built_bin if opu==1&oil==1, bin(10) percent title("landlord pay oil") scheme(s1mono) name(built_bin1, replace) xlabel(1900(50)2000) ylabel(0(20)40) ytitle("Percent", height(5)) nodraw
hist built_bin if opu==1&oil==0, bin(10) percent title("landlord pay gas") scheme(s1mono) name(built_bin2, replace) xlabel(1900(50)2000) ylabel(0(20)40) ytitle("Percent", height(5)) nodraw
hist built_bin if opu==0&oil==1, bin(10) percent title("tenant pay oil") scheme(s1mono) name(built_bin3, replace) xlabel(1900(50)2000) ylabel(0(20)40) ytitle("Percent", height(5)) nodraw
hist built_bin if opu==0&oil==0, bin(10) percent title("tenant pay gas") scheme(s1mono) name(built_bin4, replace) xlabel(1900(50)2000) ylabel(0(20)40) ytitle("Percent", height(5)) nodraw
graph combine built_bin1 built_bin2 built_bin3 built_bin4, title("Decade Built") scheme(s1mono) name(cov4, replace) nodraw

hist degree if opu==1&oil==1, discrete percent title("landlord pay oil") scheme(s1mono) name(room1, replace) xlabel(0(1)3) ylabel(0(20)60) ytitle("Percent", height(5)) nodraw
hist degree if opu==1&oil==0, discrete percent title("landlord pay gas") scheme(s1mono) name(room2, replace) xlabel(0(1)3) ylabel(0(20)60) ytitle("Percent", height(5)) nodraw
hist degree if opu==0&oil==1, discrete percent title("tenant pay oil") scheme(s1mono) name(room3, replace) xlabel(0(1)3) ylabel(0(20)60) ytitle("Percent", height(5)) nodraw
hist degree if opu==0&oil==0, discrete percent title("tenant pay gas") scheme(s1mono) name(room4, replace) xlabel(0(1)3) ylabel(0(20)60) ytitle("Percent", height(5)) nodraw
graph combine room1 room2 room3 room4, title("Degree Day Scale") scheme(s1mono) name(cov5, replace) nodraw

hist metro3 if opu==1&oil==1&metro3>0, discrete percent title("landlord pay oil") scheme(s1mono) name(room1, replace) xlabel(0(1)5) ylabel(0(20)60) ytitle("Percent", height(5)) nodraw
hist metro3 if opu==1&oil==0&metro3>0, discrete percent title("landlord pay gas") scheme(s1mono) name(room2, replace) xlabel(0(1)5) ylabel(0(20)60) ytitle("Percent", height(5)) nodraw
hist metro3 if opu==0&oil==1&metro3>0, discrete percent title("tenant pay oil") scheme(s1mono) name(room3, replace) xlabel(0(1)5) ylabel(0(20)60) ytitle("Percent", height(5)) nodraw
hist metro3 if opu==0&oil==0&metro3>0, discrete percent title("tenant pay gas") scheme(s1mono) name(room4, replace) xlabel(0(1)5) ylabel(0(20)60) ytitle("Percent", height(5)) nodraw
graph combine room1 room2 room3 room4, title("Urbanization Scale") scheme(s1mono) name(cov6, replace) nodraw
graph combine cov1 cov2 cov3 cov4 cov5 cov6, col(2) scheme(s1mono) title("Distribution of Covariates by Heating" "Fuel and Payment Regime") name(comb,replace) nodraw
graph display comb, ysize(16) xsize(10) 
graph export FigureB1.pdf, as(pdf) replace
