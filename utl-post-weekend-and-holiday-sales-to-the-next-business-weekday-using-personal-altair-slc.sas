%let pgm=utl-altair-personal-slc-post-holiday-and-weekend-sales-to-the-following-business-day;

%stop_submission;

RE: Post weekend sales and holiday sales to the next business weekday using personal altair slcT

Too long to post on a listserv, see github

https://community.altair.com/discussion/64205

OPS EXPLANATION
"I need to find a way to group or aggregate transaction amounts done on Saturday,
and Sunday (or on a holiday) to show their total on the next business day."

github
https://github.com/rogerjdeangelis/utl-post-weekend-and-holiday-sales-to-the-next-business-weekday-using-personal-altair-slc

OPS EXPLANATION
"I need to find a way to group or aggregate transaction amounts done on Saturday,
and Sunday (or on a holiday) to show their total on the next business day"

community.altair
https://tinyurl.com/4fpjzunv
https://community.altair.com/discussion/64205

Post weekend sales and holiday sales to the next business weekday

PROBLEM ADD WEEKEND AND US FEDERAL HOLIDAY SALES TO THE NEXT BUSINESS WEEKDAY
-----------------------------------------------------------------------------

Note you can easily use the FLG to change weekends and holidays trans to 0,
or remove weekends and holidays.

   DTC        NAME         TRANS    TRANSNEW    FLG

2025-01-01    NEWYEAR        74          0       1
2025-01-02    Thursday       40        114       0
                            ===
                            114

2025-01-03    Friday         85         85       0

2025-01-04    WEEKEND        26          0       1
2025-01-05    WEEKEND        27          0       1
2025-01-06    Monday         66        119       0
                            ===
                            119

2025-01-07    Tuesday        46         46       0
2025-01-08    Wednesday      31         31       0
2025-01-09    Thursday       47         47       0
2025-01-10    Friday         40         40       0

2025-01-11    WEEKEND        80          0       1
2025-01-12    WEEKEND        27          0       1
2025-01-13    Monday         70        177       0
                            ===
                            177

2025-01-14    Tuesday        28         28       0
2025-01-15    Wednesday      29         29       0
2025-01-16    Thursday       64         64       0
2025-01-17    Friday         33         33       0

2025-01-18    WEEKEND        87          0       1
2025-01-19    WEEKEND        18          0       1
2025-01-20    MLK            22          0       1
2025-01-21    Tuesday        82        209       0
                            ===
                            209

/*                   _
(_)_ __  _ __  _   _| |_
| | `_ \| `_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
*/

WORK.CALENDAR

Obs       DTC         DTN     TRANS

  1    2025-01-01    23742      74
  2    2025-01-02    23743      40
  3    2025-01-03    23744      85
  4    2025-01-04    23745      26
  5    2025-01-05    23746      27
  6    2025-01-06    23747      66
  7    2025-01-07    23748      46
  8    2025-01-08    23749      31
  9    2025-01-09    23750      47
 10    2025-01-10    23751      40
 ....

data calendar ;
  retain dtc dtn trans;
  call streaminit(4321);
  /* Replace with the actual range needed */
  do dtn = '01JAN2025'd to '31DEC2025'd;
    dtc=put(dtn,e8601da.);
    trans=floor(10 + (90-10+1)*rand("uniform"));
    output;
  end;
run;quit;

/*--- lookup ---*/
proc format;
 value $holidayname
  '2025-01-01' = 'NEWYEAR       '
  '2025-01-20' = 'MLK           '
  '2025-02-17' = 'USPRESIDENTS  '
  '2025-04-20' = 'EASTER        '
  '2025-05-26' = 'MEMORIAL      '
  '2025-07-04' = 'USINDEPENDENCE'
  '2025-09-01' = 'LABOR         '
  '2025-11-11' = 'VETERANS      '
  '2025-11-27' = 'THANKSGIVING  '
  '2025-12-25' = 'CHRISTMAS     '
  other        = 'FALSE'
;;;;
run;quit;

/*
| | ___   __ _
| |/ _ \ / _` |
| | (_) | (_| |
|_|\___/ \__, |
         |___/
*/
6482
6483      data calendar ;
6484        retain dtc dtn trans;
6485        call streaminit(4321);
6486        /* Replace with the actual range needed */
6487        do dtn = '01JAN2025'd to '31DEC2025'd;
6488          dtc=put(dtn,e8601da.);
6489          trans=floor(10 + (90-10+1)*rand("uniform"));
6490          output;
6491        end;
6492      run;

NOTE: Data set "WORK.calendar" has 365 observation(s) and 3 variable(s)
NOTE: The data step took :
      real time : 0.004
      cpu time  : 0.015


6492    !     quit;
6493
6494      proc format;
6495       value $holidayname
6496        '2025-01-01' = 'NEWYEAR       '
6497        '2025-01-20' = 'MLK           '
6498        '2025-02-17' = 'USPRESIDENTS  '
6499        '2025-04-20' = 'EASTER        '
6500        '2025-05-26' = 'MEMORIAL      '
6501        '2025-07-04' = 'USINDEPENDENCE'
6502        '2025-09-01' = 'LABOR         '
6503        '2025-11-11' = 'VETERANS      '
6504        '2025-11-27' = 'THANKSGIVING  '
6505        '2025-12-25' = 'CHRISTMAS     '
6506        other        = 'FALSE'
6507      ;;;;
NOTE: Format $holidayname output
6508      run;quit;
NOTE: Procedure format step took :
      real time : 0.012
      cpu time  : 0.000

/*
 _ __  _ __ ___   ___ ___  ___ ___
| `_ \| `__/ _ \ / __/ _ \/ __/ __|
| |_) | | | (_) | (_|  __/\__ \__ \
| .__/|_|  \___/ \___\___||___/___/
|_|
*/


data wekhol /view=wekhol;
  retain dtc name flg trans dtn;
  retain cum 0;
  set calendar(obs=40);
  name=put(dtc,$holidayName.);
  if name ne "FALSE"
     or weekday(dtn) in (1,7) then flg=1;
  else do;
     flg=0;
     name=put(dtn, dowName. -l);
  end;
  if flg then cum=cum + trans;
  else cum=0;
  keep dtc dtn name flg trans cum;
run;quit;

proc print data=wekhol;
run;quit;


INTERMEDIATE VIEW

VIEW WEKHOL.WPD

Note if we sum flg(s)=1 to first 0 we will post agregate to next business day

   DTC          NAME       FLG    TRANS     DTN     CUM

2025-01-01    NEWYEAR       1       74     23742     74
2025-01-02    Thursday      0       40     23743      0
2025-01-03    Friday        0       85     23744      0
2025-01-04    FALSE         1       26     23745     26
2025-01-05    FALSE         1       27     23746     53
2025-01-06    Monday        0       66     23747      0
2025-01-07    Tuesday       0       46     23748      0
....

/*
| | ___   __ _
| |/ _ \ / _` |
| | (_) | (_| |
|_|\___/ \__, |
         |___/
*/

6510
6511      data wekhol /view=wekhol;
6512        retain dtc name flg trans dtn;
6513        retain cum 0;
6514        set calendar(obs=40);
6515        name=put(dtc,$holidayName.);
6516        if name ne "FALSE"
6517           or weekday(dtn) in (1,7) then flg=1;
6518        else do;
6519           flg=0;
6520           name=put(dtn, dowName. -l);
6521        end;
6522        if flg then cum=cum + trans;
6523        else cum=0;
6524        keep dtc dtn name flg trans cum;
6525      run;

NOTE: The data step took :
      real time : 0.049
      cpu time  : 0.000


6525    !     quit;
6526
6527      proc print data=wekhol;
6528      run;quit;
NOTE: 40 observations were read from "WORK.calendar"

NOTE: The data step view execution took :
      real time : 0.003
      cpu time  : 0.000
NOTE: 40 observations were read from "WORK.calendar"

NOTE: The data step view execution took :
      real time : 0.002
      cpu time  : 0.000
NOTE: 40 observations were read from "WORK.wekhol"
NOTE: Procedure print step took :
      real time : 0.026
      cpu time  : 0.000

/*         _ _
 _ __ ___ | | |_   _ _ __
| `__/ _ \| | | | | | `_ \
| | | (_) | | | |_| | |_) |
|_|  \___/|_|_|\__,_| .__/
                    |_|
*/

data want;
  retain dtc  name trans transnew flg;
  set wekhol;
  by flg notsorted;
  cumlag=lag(cum);
  if  first.flg
      and flg=0
      and _n_>1 then transtmp=trans+cumlag;
  else transtmp=trans;
  if name=:'FALSE' then name="WEEKEND";
  transnew=transtmp*(1-flg);
  drop cum cumlag dtn transtmp ;
run;quit;

proc print data=want;
run;quit;


Obs       DTC          NAME       TRANS    TRANSNEW    FLG

  1    2025-01-01    NEWYEAR        74          0       1
  2    2025-01-02    Thursday       40        114       0
  3    2025-01-03    Friday         85         85       0
  4    2025-01-04    WEEKEND        26          0       1
  5    2025-01-05    WEEKEND        27          0       1
  6    2025-01-06    Monday         66        119       0
  7    2025-01-07    Tuesday        46         46       0
  8    2025-01-08    Wednesday      31         31       0
  9    2025-01-09    Thursday       47         47       0
 10    2025-01-10    Friday         40         40       0
 11    2025-01-11    WEEKEND        80          0       1
....

/*
| | ___   __ _
| |/ _ \ / _` |
| | (_) | (_| |
|_|\___/ \__, |
         |___/
*/

6635      data want;
6636        retain dtc  name trans transnew flg;
6637        set wekhol;
6638        by flg notsorted;
6639        cumlag=lag(cum);
6640        if  first.flg
6641            and flg=0
6642            and _n_>1 then transtmp=trans+cumlag;
6643        else transtmp=trans;
6644        if name=:'FALSE' then name="WEEKEND";
6645        transnew=transtmp*(1-flg);
6646        drop cum cumlag dtn transtmp ;
6647      run;

NOTE: 40 observations were read from "WORK.calendar"

NOTE: The data step view execution took :
      real time : 0.002
      cpu time  : 0.000
NOTE: 40 observations were read from "WORK.wekhol"
NOTE: Data set "WORK.want" has 40 observation(s) and 5 variable(s)
NOTE: The data step took :
      real time : 0.008
      cpu time  : 0.015


6647    !     quit;
6648
6649      proc print data=want;
6650      run;quit;
NOTE: 40 observations were read from "WORK.want"
NOTE: Procedure print step took :
      real time : 0.023
      cpu time  : 0.000

/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/

