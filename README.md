# Asymmetric-Information
Code base for Asymmetric Information in Rental Housing Markets: Implications for the Energy Efficiency Gap

This is a short readme file describing the data and code used in the paper.  

There are 3 .do files to clean an munge the data for analysis:

1) ahs_clean_97_09.do: inputs and appends raw American Housing Survey data for the years 1997--2009 in one file: ahs_data_97_09.dta
2) ahs_clean_full.do: inputs raw American Housing Survey data for the years 1985--1995 and appends them with the data from survey years 1997--2009 (ahs_data_97_09.dta).  The output file ahs_full.dta contains AHS survey data for 1985--2009 for a subset of variables used in the analysis.
3) data_build.do: combines the AHS data, fuel price data, and CPI data and creates the variables used in the analysis.

Run each of these 3 files in turn to create the data sets used in the analysis: 1) renter_full.dta, 2) turnover_full.dta, 2) switch_oil.dta.  These are outputs of data_build.  The code is currently written to store these in the ``Clean Data'' folder.

American Housing Survey Data
The raw American Housing Survey data are located in the ``Raw Data'' folder
1) ahs85_95 contains the raw data for surveys 1985--1995
2) ahsYYYY contains the raw data for survey year YYYY
3) AHS_1997_SAMEHH_fix has a correction for the `samehh' variable for the survey year 1997.  The Readme.txt document in the folder was provided by staff of the AHS and explains the fix in detail.

Fuel Prices and CPI:
There are 9 publicly available data sets for creating fuel price measures.  The source of the data is listed here and discussed in the paper 
1) state_gas_price.csv: Annual state-level residential natural gas prices from the EIA
2) state_gas_cons.csv: Annual state-level natural gas sales from the EIA
3) state_oil_price.csv: Annual state-level residential heating oil prices from the EIA
4) state_oil_cons.csv: Annual state-level heating oil sales from the EIA
5) state_gas_price_monthly.csv: Monthly state-level residential natural gas prices from the EIA (only available at the state level starting in 1989)
6) state_gas_cons_monthly.csv: Monthly state-level residential natural gas sales from the EIA (only available at the state level starting in 1989)
7) state_oil_price_monthly.csv: Monthly state-level residential heating oil prices from the EIA 
8) state_oil_cons_monthly.csv: Monthly state-level residential heating oil sales from the EIA
9) cpi.dta: Consumer price index from BLS

Figures and Tables:
There are separate .do files for creating each Figure and Table in the main text.  Each is labeled "FigureX.do" or "TableX.do," where the X corresponds to the table number in the paper.  The folder "Appendix Tables and Figures" contains similar .do files for the tables and figures in the appendix.


Please do not hesitate to contact me to provide further clarification. 


Erica Myers

University of Illinois

Agricultural and Consumer Economics

Phone: 217-300-2023

ecmyers@illinois.edu
