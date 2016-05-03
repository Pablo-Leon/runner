#
# Makefile -- Runner project / Carreras
#


SOURCE_FILES=Makefile runner_lib.pl test_runner_lib.pl get_chronotrack.pl
	
X_FILES= xp1.pl x_chronotrack.sh

PERL_EXE=/usr/bin/perl

.PHONY: all clean bkp chk file
.SUFFIXES: .Rmd .html


all: segment

hello :
	echo "Hello!."
	
clean:
	-rm *.trc
	-rm trc/*.*
	-rm *.csv
	-rm *.html
	-rm event*.txt
	-rm -r html_files
		
bkp : 
	bak.pl $(SOURCE_FILES)
	bak.pl $(X_FILES)
	
chk:
	clear
	$(PERL_EXE) -c xp2.pl
	$(PERL_EXE) -c get_chronotrack.pl

file : 
	file *.csv *.trc *.pl
	
x : 
	time ./xp2.pl --trace

# event-20591.42k.csv : event-20591.42k.txt
# 	time ./get_chronotrack.pl --infile=$< --outfile=$@ --trace	
# 
# event-20591.10k.csv : event-20591.10k.txt
# 	time ./get_chronotrack.pl --infile=$< --outfile=$@ --trace	

xprof : 
	time /usr/bin/perl -d:NYTProf ./xp2.pl 
	nytprofhtml --open	

mds2015.csv :	
	time ./get_chronotrack.pl --event_name="mds2015" --trace

mds2014.csv :	
	time ./get_chronotrack.pl --event_name="mds2014" --trace

