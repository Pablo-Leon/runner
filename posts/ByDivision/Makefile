#
# Makefile
#

RMDFILE=by_division

DATA_FILES=Brooks50.csv mds2014.csv mds2015.csv mds2016.csv

SRCDATA_DIR=../../../Data
PUBLISH_DIR=../publish

PERL_SOURCE_FILES=
R_SOURCE_FILES=eda.R eda2.R

SOURCE_FILES=Makefile $(PERL_SOURCE_FILES) \
	$(R_SOURCE_FILES) $(RMDFILE).Rmd 

.PHONY: all clean heads wdata chk bkp
.SUFFIXES:.Rmd .html .pdf


all: data $(RMDFILE).html

hello:
	echo "Hello!"

publish: $(RMDFILE).pdf
	cp $^ $(PUBLISH_DIR)/.
	git add $(PUBLISH_DIR)/$^


#	Rscript -e "rmarkdown::render('$(RMDFILE).Rmd', clean=FALSE)"
.Rmd.html:	
	Rscript -e "rmarkdown::render('$(RMDFILE).Rmd', rmarkdown::html_document(self_contained = FALSE))"

.Rmd.pdf:	
	# pandoc +RTS -K64M -RTS -o $@  $<
	Rscript -e "rmarkdown::render('$(RMDFILE).Rmd', rmarkdown::pdf_document())"

clean:
	-rm *.trc $(RMDFILE).html $(RMDFILE).pdf
	-rm $(RMDFILE).knit.md $(RMDFILE).utf8.md 
	-rm -r *_cache *_files

clean-all: clean
	-rm $(DATA_FILES)

chk:
	clear
	perl -c $(PERL_SOURCE_FILES)

bkp:
	bak.pl $(SOURCE_FILES) $(DATA_FILES)

x: 
	sed 's/\([^;]\)"\([^;]\)/\1~\2/' 	mds2016.csv > sal.txt
	# sed 's/;Renato federico Sebastian Rojas Dall."Orso;/;Renato federico Sebastian Rojas Dall~Orso;/' 	mds2016.csv > sal.txt

data: $(DATA_FILES)

$(DATA_FILES): $(SRCDATA_DIR)/$@
	# cp $(SRCDATA_DIR)/$@ .
	sed 's/\([^;]\)"\([^;]\)/\1~\2/' $(SRCDATA_DIR)/$@ > $@

browse:
	google-chrome $(RMDFILE).html

