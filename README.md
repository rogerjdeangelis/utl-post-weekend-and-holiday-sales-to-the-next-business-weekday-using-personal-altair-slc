# utl-post-weekend-and-holiday-sales-to-the-next-business-weekday-using-personal-altair-slc
Post weekend sales and holiday sales to the next business weekday using personal altair slc
    %let pgm=utl-post-weekend-and-holiday-sales-to-the-next-business-weekday-using-personal-altair-slc;

    %stop_submission;

    Post weekend sales and holiday sales to the next business weekday using personal altair slc

    github
    https://tinyurl.com/36usnkpn
    https://github.com/rogerjdeangelis/utl-post-weekend-and-holiday-sales-to-the-next-business-weekday-using-personal-altair-slc

    OPS EXPLANATION
    "I need to find a way to group or aggregate transaction amounts done on Saturday,
    and Sunday (or on a holiday) to show their total on the next business day"

    SOAPBOX ON
      I am new to the Personal SLC
      Personal Altair SLC does not support any of the four SAS Holiday functions.
      Not a big deal because Holiidays vary
    SOAPBOX OFF

    community.altair
    https://tinyurl.com/4fpjzunv
    https://community.altair.com/discussion/64205/how-can-i-aggregate-or-group-monetary-transactions-on-the-next-business-day?tab=all&utm_source=community-search&utm_medium=organic-search&utm_term=mone

    Post weekend sales and holiday sales to the next business weekday

    PROBLEM ADD WEEKEND AND US FEDERAL HOLIDAY SALES TO THE NEXT BUSINESS WEEKDAY
    -----------------------------------------------------------------------------

    Note you can easily use the FLG to change weekends and holidays trans to 0,
    or remove weekends and holidays.

     DTC       NAME      TRANS TRANSNEW                        FLG  trans*(1-FLG) will zero out weekends & holidays

    2025-01-01 NEWYEAR     74    74                             1
    2025-01-02 Thursday    40   114 74+40=114 (add Thursday)    0

    2025-01-03 Friday      85    85                             0
    2025-01-04 Saturday    26    26                             0
    2025-01-05 Sunday      27    27                             0
    2025-01-06 Monday      66   119                             0
    2025-01-07 Tuesday     46    46                             0
    2025-01-08 Wednesday   31    31                             0
    2025-01-09 Thursday    47    47                             0
    2025-01-10 Friday      40    40                             0
                                                                0
    2025-01-11 Saturday    80    80                             1
    2025-01-12 Sunday      27    27 107                         1

    2025-01-13 Monday      70   177 107+77=177                  0
    2025-01-14 Tuesday     28    28                             0
    2025-01-15 Wednesday   29    29                             0
    2025-01-16 Thursday    64    64                             0
    2025-01-17 Friday      33    33                             0

    2025-01-18 Saturday    87    87                             1
    2025-01-19 Sunday      18    18                             1
    2025-01-20 MLK         22    22 87+18+22=127  (AT+SUN+MON)  1

    2025-01-21 Tuesday     82   209 127+82=209                  0

    /*                   _
    (_)_ __  _ __  _   _| |_
    | | `_ \| `_ \| | | | __|
    | | | | | |_) | |_| | |_
    |_|_| |_| .__/ \__,_|\__|
            |_|
    */

        DT        TRANS

    2025-01-01      74
    2025-01-02      40
    2025-01-03      85
    2025-01-04      26
    2025-01-05      27
    ...

    &_init_;
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
     _ __  _ __ ___   ___ ___  ___ ___
    | `_ \| `__/ _ \ / __/ _ \/ __/ __|
    | |_) | | | (_) | (_|  __/\__ \__ \
    | .__/|_|  \___/ \___\___||___/___/
    |_|
    */

    /*--- cumulate run length of tranactions for holiday plus weekends  ---*/

    data wekhol /view=wekhol;
      retain dtc name flg trans;
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
      keep dtc name flg trans cum;
    run;quit;

    proc print data=wekhol;
    run;quit;


       DTC        NAME         FLG    TRANS    CUM

    2025-01-01    NEWYEAR       1       74      74
    2025-01-02    Thursday      0       40       0
    2025-01-03    Friday        0       85       0
    2025-01-04    FALSE         1       26      26
    2025-01-05    FALSE         1       27      53
    2025-01-06    Monday        0       66       0
    2025-01-07    Tuesday       0       46       0
    2025-01-08    Wednesday     0       31       0
    2025-01-09    Thursday      0       47       0
    2025-01-10    Friday        0       40       0
    2025-01-11    FALSE         1       80      80
    2025-01-12    FALSE         1       27     107
    2025-01-13    Monday        0       70       0
    2025-01-14    Tuesday       0       28       0
    2025-01-15    Wednesday     0       29       0
    2025-01-16    Thursday      0       64       0
    2025-01-17    Friday        0       33       0
    2025-01-18    FALSE         1       87      87
    2025-01-19    FALSE         1       18     105
    2025-01-20    MLK           1       22     127
    2025-01-21    Tuesday       0       82       0

    /*              _
      ___ _ __   __| |
     / _ \ `_ \ / _` |
    |  __/ | | | (_| |
     \___|_| |_|\__,_|

    */
