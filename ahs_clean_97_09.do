clear
set mem 24g
set more off

*set path to the "Raw Data" folder here
global dirpath "C:\Users\ecmyers\Dropbox\AHS\Replication\Raw Data"

cd "$dirpath"

********************************************************************************************************
*Bring in HH data for 1997
*Create a survey year variable
*Merge with TOPPUF variables of interest
*Merge with Move variable
********************************************************************************************************

insheet using "$dirpath\ahs1997\BHOUSHLD.txt", names clear
drop if _n==1

gen survey_year = 1997

save ahs_data_97_09, replace

insheet using "$dirpath\ahs1997\BTOPPUF.txt", names clear

merge 1:1 control using ahs_data_97_09
drop _merge

destring(fhoth amte amtg amto baths bedrms built halfb usfcam whnget vacancy lot unitsf amtf hequip lprice value dens dining famrm kitch living busin othfn  /// 
recrm obedrm oafuel numair ffrpli ffrpl odin okitch tpark olivin oothrm exclus air amtt amtw atbsun cabnx cellar cprice dline1 doorx floors frent prent  ///
cstmnt hown zincn persint laundy mvcnt1 mvcnt2 mvcnt3 noint nunits othrun rent storg type vother wallx winx mh41 mh42 mh43 mh44 mh45 reuad fplwk  ///
amti camfq fmhotf mhotfe flrent lrent bedx hown howh climb fcokst fporth lvalue moperm movac peelam pvalue whymov tlrmov), replace

destring(frsit), replace ignore(')

save ahs_data_97_09, replace

insheet using "$dirpath\ahs1997\BPERSON.txt", names clear
keep control move
bysort control: egen temp = min(move)
replace move = temp
drop temp
duplicates drop
merge 1:1 control using ahs_data_97_09
drop _merge

insheet using "$dirpath\ahs1997\BWEIGHT.txt", names clear
merge 1:1 control using ahs_data_97_09
drop _merge

save ahs_data_97_09, replace


********************************************************************************************************
*Bring in HH data for 1999
*Follow similar steps
********************************************************************************************************

insheet using "$dirpath\ahs1999\thoushld.txt", names clear

gen survey_year = 1999

save temp, replace

insheet using "$dirpath\ahs1999\ttoppuf.txt", names clear

merge 1:1 control using temp
drop _merge
destring(persint), replace ignore(')

save temp, replace

insheet using "$dirpath\ahs1999\tperson.txt", names clear
keep control move
bysort control: egen temp = min(move)
replace move = temp
drop temp
duplicates drop
merge 1:1 control using temp
drop _merge

insheet using "$dirpath\ahs1999\tweight.txt", names clear
merge 1:1 control using temp
drop _merge

append using ahs_data_97_09
destring(regmor), replace ignore(')
save ahs_data_97_09, replace
erase "$dirpath\temp.dta"


********************************************************************************************************
*Now do the same for the rest of the years and append (they all have the same formatting)
********************************************************************************************************

global year 2001 2003 2005 2007 2009

foreach y in $year {
	insheet using "$dirpath\ahs`y'\tnewhouse.txt", clear
	gen survey_year=`y'
	destring(persint), replace ignore(')
	destring(hhnatvty), replace ignore(')
	append using ahs_data_97_09
	save ahs_data_97_09, replace
}

destring(date status samehh jamtg jamte jbuye jbuyg control region degree metro3 jhhage jhhitshp jhhgrad jhhnusyr jhhmar jhhage jhhitshp jhhgrad jhhnusyr jhhmar jhhmove jhhmovm jhhmvg jhhatvty jhhrace jhhrel jhhsex ///
usegas uselect jhhspan jhhspos jline1 jdate jenure jtype junit2 junits jamtg jamte jbuye jbuyg junits jharat jharfr	jreuad jccess jamedu jvacan	jedrms jbaths jfamrm jrecrm	jdens jaundy jothfn	jthrun	///
jhalfb jkitch jiving jining jvalu jrent	jfrent jbuilt jreeze jellar	jcondo jloors jclimb jelev jdirac jusper jxclus	jrshop jarage jcars	jrucks jlot	jsfchg jnitsf jtpark jporch	jcook jurner	///
joven jcfuel jrefr jsink jexclu	jdispl jtrash jdish	jwash jdry jdfuel jubsew jewdis	jewdus jotpip joilet jtub jbsink jharpf	jwfuel jwater jeldus jaters	jhfuel jequip jirsys	///
jarsys jafuel joafue jair jumair jfplwk	jaspi2 jfcold jifdry jiftlt	jleak jileak jifsew	jumsew jowire jplugs jfblow	jracks jholes jbigp	jevrod 	///
jrats jmice jotsur jvcnt1 jvcnt2 jvcnt3 jhymov jmcndo jmownr jmgovp jhyton jhytoh jalmv jmpriv jmgovt jmjobs jmclos jmfemp jmonhh jmlarg jmmarr jmfaml jmqual jmchtn jmhous	///
jmothr jwnjob jnpepl jntran	jwnsch jwnsrv jnlook jnothr	jmevic jwhfin jwhdsn jwhsiz	jwhext jwhyrd jwhqul jwhavl	jmdisl jmchep jnhome jwhoth jhnget	///
jmovac joperm jimshr jpvalu	jmarkt jrstoc jrstho jlpric	jcpric jmg jegmor jelump jiffee	jtxre jfothf jhotfe	jlrent jincs jhstay	janpmt jbuyi jamti jrenew jubrnt jproj japply jprent	///
jcntrl jbuyt2 jbuyw2 jbuye2	jbuyg2 jbuyo2 jbuyf2 jsegas	jaspip jillge jillgf jillgo	jillgt jillgw jilleg jilleo	jillef jillet jillew jamto jilloe jamtf	jillfe jamtt jillte	jamtw jillwe jillog	///
jillfg jilltg jillwg jbuyo jbuyf jillof	jillfo jillot jillto jillow	jillwo jillft jilltf jillfw	jillwf jilltw jillwt jbillg	jbille jbillf juselect jbillo jbillt juseothr jbuyt	jbuyw juseoil	///
jropsl jzincn jwnlot jvother jvother2 jqint	jqdiv jqrent jqother jqalim	jqself jqretir jqss	jqwelf jqssi jqwkcmp jhhage	jhhitshp jhhgrad jhhnusyr jhhmar jhhmove jhhmovm jhhmvg	jhhatvty jhhrace	///
jhhrel jhhsex jhhspan jhhspos jbillw dish wash dry buyg cmsa histry qself qss qssi qwelf qretir qwkcmp qint qrent qother qalim istatus qdiv), replace ignore(')
save ahs_data_97_09, replace

destring(hfuel region gaspip metro3 control), replace ignore(')
label define hfuel_lbl 1 "Elec" 2 "Gas" 3 "Fuel Oil" 4 "Kerosene" 5 "Coal/Coke" 6 "Wood" 7 "Solar" 8 "Other" 9 "None"
label values hfuel hfuel_lbl

label define region_lbl 1 "Northeast" 2 "Midwest" 3 "South" 4 "West"
label values region region_lbl

label define gaspip_lbl 1 "pipes serving neighborhood" 2 "bottled gas"
label values gaspip gaspip_lbl

label define metro3_lbl 1 "central city of MSA" 2 "inside MSA, not central city, urban" 3 "inside MSA, not central city, rural" 4 "outside MSA urban" 5 "ouside MSA rural"
label values metro3 metro3_lbl

save ahs_data_97_09, replace
