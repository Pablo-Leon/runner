#!/usr/bin/perl -w

=head1 		Copyright SQL*TECHNOLOGY 2016

=head1 NOMBRE

test_runner_lib.pl - 

=head1 SINOPSIS

   rfmt_chronotrack.pl [switches]
      --help         Obtener ayuda
      --debug        Mostrar mensajes de debug (STDERR)
      --trace        Guardar mensajes de debug en rfmt_chronotrack.pl.trc

=head1 DESCRIPCION


=head1 PARAMETROS


=head1 OBSERVACIONES

=head1 VARIABLES

=head1 PROGRAMAS ASOCIADOS

=head1 RCS

 	$Name$
	$Source$
 	$Id$

=cut

use strict;
use warnings;
use English;

# use strict 'refs';
use Data::Dumper;
use Getopt::Long ();

# use WWW::Mechanize;
# use HTTP::Cookies;
# use URI;
# use Web::Scraper;
# use Encode;
# use Date::Parse;

# use Text::CSV;
# use Text::Levenshtein qw(distance);
##---## use Text::JaroWinkler qw( strcmp95 );

# use WebService::Strava;

require "runner_lib.pl";



sub help () {
	my ($pack, $file, $line)=caller();
	system('perldoc -t '.$file);
	exit 1;
}

my ($program)=$0; $program=~s/^.*\/([^\/]+)$/$1/;
	
#
# Recibir parametros
#

my $optctl = {};

Getopt::Long::GetOptions($optctl,
	 '--help'
	,'--debug'
	,'--trace'
	,'infile=s'
	,'outfile=s'
	) || help();


if ( defined $optctl->{'help'} ) {
    help();
}


#
# Debug
#
{
my $sDbgCurrentFile='';

$::debug=sub { 1; };
if ( $::optctl->{'debug'} ) 
{
	$::debug=sub { my ( $fmt )=shift; printf(STDERR "DBG/${program}: ".$fmt."\n",@_); 1; };
	&{$::debug}("Debug activado");
	$::debugf=1;
}

$::optctl->{'trace'} = 1
	if (!defined($::optctl->{'debug'}));
if ( $::optctl->{'trace'} ) 
{
   # open TRC,  ">", "${program}.trc";
   open TRC,  ">:utf8", "${program}.trc";
	select(TRC); $OUTPUT_AUTOFLUSH=1; select(STDOUT);
	$::debug=sub {
			my ( $fmt )=shift;
			my ($package, $filename, $line) = caller;
			if ("$package:$filename" ne $sDbgCurrentFile)
			{
				print TRC sprintf("En %s:%s\n",$package,$filename);
				$sDbgCurrentFile="$package:$filename";
			}
			print TRC sprintf("[$line]: $fmt\n",@_);
			1;
		};
	&{$::debug}("Debug activado");
	$::debugf=1;
}
}


#
# Init
#

$|=1; # $OUTPUT_AUTOFLUSH=1

my ($rc);

#
# Params
#
&{$::debug}("optctl: %s", Dumper($optctl)) if($::debugf);

my $sInFile='';
$sInFile=$optctl->{'infile'}
	if (exists($optctl->{'infile'}));
die "No se encuentra archivo --infile:[$sInFile]."
	unless (-f $sInFile);
	
my $sOutFile='';
$sOutFile=$optctl->{'outfile'}
	if (exists($optctl->{'outfile'}));
# die "No se encuentra archivo --outfile:[$sOutFile]."
# 	unless (-f $sOutFile);
	
#
# Init
#



#
# Body
#

#
# Init
#



#
#
#
#


close TRC
   if($optctl->{'trace'});

exit;
###############################################################################

sub Funcion
{
	my ($sParam1, $sParam2)=@_;
	my $ret='';
	
	&{$::debug}("Funcion( %s )", join(' ', map( (defined($_)?"[$_]":'<undef>'), @_)));

	# Cuerpo de Funcion
	
	&{$::debug}("Funcion()->[%s]", $ret);
	return $ret;
}


sub Test_ChronotrackFmt()
{
	my ($dummy)=@_;
	my $ret='';
	
	&{$::debug}("Funcion( %s )", join(' ', map( (defined($_)?"[$_]":'<undef>'), @_)));

	# Cuerpo de Funcion
	my %hTexts = (
		'csv' => [
				q{"20634417","10802","Juana jul\"ia Catriñanco Donoso","19635","03:43:34","10:39","Chile, --","61","F","Damas 60 a 64 años","22"}
			]
		,'tuple' => [
				 q{["20634417","10802"]}
				,q{["10802",["Juana"],[  ]  ] }
				,q{["20634417","10802",["Juana jul\"ia Catriñanco Donoso"],[],["19635","03:43:34","10:39"],["Chile, --","61","F"],["Damas 60 a 64 años","22"]]}
			]
		,'hash' => [
				q{{"iTotalRecords":"10825","iTotalDisplayRecords":"10825","iDisplayStart":10800,"aaData":[["20636685","10801","Robert Correa Cabrera","20529","03:43:05","10:38","Chile, --","40","M","Varones 40 a 44 años","1070"]],"rowCount":"6501","unfilteredRowCount":"6501","page":1,"pageSize":"15","rowStart":0,"numPages":434,"sEcho":1,"genID":"8365592"}}
			]
		,'results' => [
				q{results_grid8365592({"iTotalRecords":"10825","iTotalDisplayRecords":"10825","iDisplayStart":10800,"aaData":[["20636685","10801","Robert Correa Cabrera","20529","03:43:05","10:38","Chile, --","40","M","Varones 40 a 44 años","1070"]],"rowCount":"6501","unfilteredRowCount":"6501","page":1,"pageSize":"15","rowStart":0,"numPages":434,"sEcho":1,"genID":"8365592"});}
			],
	);

	# foreach my $f ('csv', 'tuple', 'hash', 'results') {
	foreach my $f ('csv', 'tuple', 'hash', 'results') {
		foreach my $sText (@{$hTexts{$f}}) {
			&{$::debug}("sText:[%s]", $sText) if($::debugf);

			my $r;
			if ($f eq 'csv') {
				$r = ParseCsv(\$sText);
			} elsif ($f eq 'tuple') {
				$r = ParseTuple(\$sText);
			} elsif ($f eq 'hash') {
				$r = ParseHash(\$sText);
			} elsif ($f eq 'results') {
				$sText=~s/^results_grid8365592\(//;
				$sText=~s/\);$//;
				$r = ParseHash(\$sText);
				&{$::debug}("sText:[%s]", $sText) if($::debugf);
			}
			&{$::debug}("r: %s", Dumper($r)) if($::debugf);
			&{$::debug}("sText:[%s]", $sText) if($::debugf);
		}
	}
	&{$::debug}("Test_ChronotrackFmt()->[%s]", $ret);
	return $ret;
}



