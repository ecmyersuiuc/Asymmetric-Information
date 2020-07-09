9/19/2008

AHS 1997 SAMEHH Fix.zip contains a correction for the SAMEHH variable in
the 1997 American Housing Survey dataset.  The corrected variable is called
R_SAMEHH.

R_SAMEHH is a recreated SAMEHH for 1997.  Because SAMEHH was corrupted in
1997, users can't determine if at least one household member is present
from the previous survey.  Amy O’Hara of the Census Bureau developed
R_SAMEHH by matching the exact date of birth and sex between 1995 and 1997
internal data files.  If one (or more) persons in a household matched,
R_SAMEHH=1, else 2.

The zip archive contains two data files.  One is a SAS file, and the other
is a comma-delimited ASCII file.  The two files contain the same data.  Use
whichever one is more convenient to import into your statistical software.
Each file contains two variables: CONTROL and R_SAMEHH.  CONTROL is the
standard AHS record ID number.  R_SAMEHH is the corrected SAMEHH variable.
To merge the new variable with your existing AHS data, sort both files by
CONTROL and then match the records on that variable.  In SAS, you would do
something similar to this:

PROC SORT DATA=AHS97.Househld;
     BY Control;
RUN;

PROC SORT DATA=PUF97_SameHH;
     BY Control;
RUN;

DATA AHS97.Househld;
     MERGE AHS97.Househld PUF97_SameHH;
     BY Control;
RUN;

The exact syntax depends on your file system and whether you are using the
multifile or flat file version of the AHS dataset.

Contact:
-------
David A. Vandenbroucke
Senior Economist
U.S. Dept. HUD
451 7th Street SW, Room 8218
Washington, DC    20410

email:  david.a.vandenbroucke@hud.gov
phone:  202-402-5890
fax:    202-708-3316

