#
# Makefile
#

RMDFILE=runner1

DATA_FILES=Brooks50.csv

SRCDATA_DIR=../../Data
PUBLISH_DIR=../publish

PERL_SOURCE_FILES=
SOURCE_FILES=Makefile $(PERL_SOURCE_FILES) \
	eda1.R $(RMDFILE).Rmd 

.PHONY: all clean heads wdata chk bkp publish
.SUFFIXES:.Rmd .html


all: data $(RMDFILE).html

hello:
	echo "Hello!"

publish: runner1.pdf
	cp $^ $(PUBLISH_DIR)/.
	git add $(PUBLISH_DIR)/$^

.Rmd.html:	
	Rscript -e "rmarkdown::render('$(RMDFILE).Rmd')"

.Rmd.pdf:	
	# pandoc +RTS -K64M -RTS -o $@  $<
	Rscript -e "rmarkdown::render('$(RMDFILE).Rmd', pdf_document())"

clean:
	-rm *.trc $(RMDFILE).html $(RMDFILE).pdf
	-rm -r *_cache *_files

clean-all: clean
	-rm $(DATA_FILES)

chk:
	clear
	perl -c $(PERL_SOURCE_FILES)

bkp:
	bak.pl $(SOURCE_FILES) $(DATA_FILES)

data: $(DATA_FILES)

Brooks50.csv: $(SRCDATA_DIR)/$@
	cp $(SRCDATA_DIR)/$@ .

browse:
	google-chrome $(RMDFILE).html

