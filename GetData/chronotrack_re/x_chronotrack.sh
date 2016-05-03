#!/bin/sh


# https://admin.chronotrack.com/admin



# date -d @1459875822776 -> "Tue 16 Aug 18:52:56 CLST 48231"
# perl -le 'print scalar localtime $ARGV[0]' 1234567890

# Otros resultados:
# #  https://results.chronotrack.com/event/results/event/event-XXXXXX
# MDS 2016 : event-20591, Santiago, Chile    Apr 3, 2016 7:00AM
# MDS 2015 : event-13311, Santiago, Chile    Apr 12, 2015 8:00AM
# MDS 2014 : event-8069,
#
# www.maratondesantiago.com/apps/resultados.php
# 2013, 2012, 2011, 2010, 2009, 2008. 
#

nStart=0
nLength=100
nPause=2

#
# 21k
#
sEvent=20591
sRace=49990
nMax=10825
bracketID=525512
intervalID=100805

sOutfile="event-${sEvent}.21k.txt"

#
# 10k
#
sOutfile="event-${sEvent}.10k.txt"

sRace=49989
bracketID='525509'
intervalID='100804'

sEcho=5

nLength=100
nMax=6501

#
# 42k
#
sOutfile="event-${sEvent}.42k.txt"

sRace=49991
bracketID='525515'
intervalID='100806'
nMax=4590


#nMax=10


{
echo "# sEvent:[$sEvent]"
echo "# sRace:[$sRace]"
echo "# bracketID:[$bracketID]"
echo "# intervalID:[$intervalID]"
} > $sOutfile


#42k
# curl 'https://results.chronotrack.com/embed/results/results-grid
# ?callback=results_grid8365592&sEcho=7
# &iColumns=11&sColumns=
# &iDisplayStart=0&iDisplayLength=15
# &mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4
# &mDataProp_5=5&mDataProp_6=6&mDataProp_7=7&mDataProp_8=8&mDataProp_9=9
# &mDataProp_10=10
# &userID=&lc=en
# &raceID=49991
# &bracketID=525515
# &intervalID=100806
# &entryID=&eventID=20591
# &eventTag=event-20591
# &oemID=www.chronotrack.com
# &userID=630456146&genID=8365592
# &x=1459980608249&_=1459980608255' 


# 10k
# curl 'https://results.chronotrack.com/embed/results/results-grid
# ?callback=results_grid8365592&sEcho=5
# &iColumns=11&sColumns=
# &iDisplayStart=0&iDisplayLength=50
# &mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4
# &mDataProp_5=5&mDataProp_6=6&mDataProp_7=7&mDataProp_8=8&mDataProp_9=9
# &mDataProp_10=10
# &userID=&lc=en
# &raceID=49989
# &bracketID=525509
# &intervalID=100804
# &entryID=&eventID=20591
# &eventTag=event-20591
# &oemID=www.chronotrack.com
# &userID=630456146&genID=8365592
# &x=1459977794004&_=1459977794007' 


# 21k , 1ra pag de 100 filas
# curl 'https://results.chronotrack.com/embed/results/results-grid
# ?callback=results_grid8365592&sEcho=8
# &iColumns=11&sColumns=
# &iDisplayStart=0&iDisplayLength=100
# &mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4
# &mDataProp_5=5&mDataProp_6=6&mDataProp_7=7&mDataProp_8=8&mDataProp_9=9
# &mDataProp_10=10
# &userID=&lc=en
# &raceID=49990
# &bracketID=525512
# &intervalID=100805
# &entryID=&eventID=20591
# &eventTag=event-20591
# &oemID=www.chronotrack.com
# &userID=630456146&genID=8365592
# &x=1459875822772&_=1459875822776' 
#
#


while [ "$nStart" -lt "$nMax" ]; do

sUrl="https://results.chronotrack.com/embed/results/results-grid\
?callback=results_grid8365592\
&sEcho=${sEcho}\
&iColumns=11&sColumns=\
&iDisplayStart=${nStart}&iDisplayLength=${nLength}\
&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4\
&mDataProp_5=5&mDataProp_6=6&mDataProp_7=7&mDataProp_8=8&mDataProp_9=9\
&mDataProp_10=10\
&userID=&lc=en\
&raceID=${sRace}\
&bracketID=${bracketID}\
&intervalID=${intervalID}\
&entryID=&eventID=${sEvent}\
&eventTag=event-${sEvent}\
&oemID=www.chronotrack.com\
&userID=630456146&genID=8365592\
&x=1459875822772&_=1459875822776"

sCookie='Cookie: _gig_llp=facebook; _gig_llu=Pablo; hsfirstvisit=https%3A%2F%2Fwww.chronotrack.com%2Fprivacy-policy%2F|https%3A%2F%2Fapi.chronotrack.com%2Fdev%2Fapp%2Fterms|1457363483828; chronotrack_secure_sid=4faj1mdhorg52gk18srqi199a5; CT=0kaq0bsal83e0majni0qv77af2; CT_QA=4s0vu7763vd79k7b0l6u67m9s4; CT_LANG=en; __utma=38466033.630456146.1457363483.1459869431.1459875974.4; __utmc=38466033; __utmz=38466033.1457363483.1.1.utmcsr=api.chronotrack.com|utmccn=(referral)|utmcmd=referral|utmcct=/dev/app/terms; _ga=GA1.2.630456146.1457363483; __hstc=46660728.429f965715707880aaf329225e9a7a07.1457363483831.1459869432187.1459875975860.4; __hssrc=1; hubspotutk=429f965715707880aaf329225e9a7a07; CT_ACCOUNT_ID=11324146; _gat_UA-34134613-4=1; _ga=GA1.3.389360205.1457362544'



set -x
curl "$sUrl" \
	-H 'Accept: text/javascript, application/javascript, application/ecmascript, application/x-ecmascript, */*; q=0.01' \
	-H 'X-NewRelic-ID: Vg8EVlRbGwIFVFhRBwcB' \
	-H 'Referer: https://results.chronotrack.com/event/results/event/event-20591' \
	-H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.110 Safari/537.36' \
	-H 'X-Requested-With: XMLHttpRequest' \
	-H 'Accept-Encoding: gzip, deflate, sdch' \
	-H 'Accept-Language: es-419,es;q=0.8,de;q=0.6,en;q=0.4,ru;q=0.2' \
	-H "$sCookie" \
	-H 'Connection: keep-alive' \
	 --compressed	\
	>> $sOutfile
set +x
echo >> $sOutfile


nStart=`expr $nStart + $nLength`

echo "Pause ..."
sleep $nPause

done

