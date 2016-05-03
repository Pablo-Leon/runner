#!/usr/bin/perl -w

=head1 		Copyright SQL*TECHNOLOGY 2016

=head1 NOMBRE

get_chronotrack.pl - 

=head1 SINOPSIS

   get_chronotrack.pl [switches]
      --help         Obtener ayuda
      --event_name=<name>
      					Event Name
      --debug        Mostrar mensajes de debug (STDERR)
      --trace        Guardar mensajes de debug en get_chronotrack.pl.trc

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

use Encode qw(decode encode encode_utf8);
use utf8;


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
	,'event_name=s'
	) || help();


if ( defined $optctl->{'help'} ) {
    help();
}

if ( defined $optctl->{'sqltech'} ) {
    $ENV{'SQLTECHHOME'}=$optctl->{'sqltech'};
}

die 'Environment Variable SQLTECHHOME is undefined'
	unless defined $ENV{'SQLTECHHOME'} ;


#
# Debug
#
{
my $sDbgCurrentFile='';

$::debug=sub { 1; };
if ( $optctl->{'debug'} ) 
{
	$::debug=sub { my ( $fmt )=shift; printf(STDERR "DBG/${program}: ".$fmt."\n",@_); 1; };
	&{$::debug}("Debug activado");
	$::debugf=1;
}

$optctl->{'trace'} = 1
	if (!defined($optctl->{'debug'}));
if ( $optctl->{'trace'} ) 
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

#
# Init
#



#
# Body
#

#
# Init
#


sub GetChronotrackPage($$$$$$);
sub BslashU2UTF($);

#
# TEST
#
#

# my $sEventName='mds2015';


my $rEvents={
	'mds2016' => {
		 'event'	=> 20591
		,'races' => [
			 { 'name'=> '10k', 'race' => 49989, 'bracketID' => 525509, 'intervals' => [
			 	[ 'complete', 100804 ]
			 	]}
			,{ 'name'=> '21k', 'race' => 49990, 'bracketID' => 525512, 'intervals' => [
			 	[ 'complete', 100805 ]
			 	]}
			,{ 'name'=> '42k', 'race' => 49991, 'bracketID' => 525515, 'intervals' => [
			 	[ 'complete', 100806 ]
			 	]}
			]
		}
	,'mds2015' => {
		 'event'	=> 13311
		,'races' => [
			 { 'name'=> '10k', 'race' => 30945, 'bracketID' => 317827, 'intervals' => [
			 	 [ 'complete', 60019 ]
			 	]}
			,{ 'name'=> '21k', 'race' => 30946, 'bracketID' => 317830, 'intervals' => [
			 	 [ 'complete', 60020 ]
			 	,[ '11K',      62425 ]
			 	,[ '14.8K',    62426 ]
			 	]}
			,{ 'name'=> '42k', 'race' => 30947, 'bracketID' => 317833, 'intervals' => [
			 	 [ 'complete', 60021 ]
			 	,[ '11K',      62442 ]
			 	,[ '14.8K',    62443 ]
			 	,[ '21.1K',    62444 ]
			 	,[ '25K',      62445 ]
			 	,[ '32.2K',    62446 ]
			 	,[ '35K',      62512 ]
			 	]}
			]
		}
	,'mds2014' => {
		 'event'	=> 8069
		,'races' => [
			 { 'name'=> '10k', 'race' => 17230, 'bracketID' => 169184, 'intervals' => [
			 	 [ 'complete', 29346 ]
			 	]}
			,{ 'name'=> '21k', 'race' => 17231, 'bracketID' => 169212, 'intervals' => [
			 	 [ 'complete', 29347 ]
			 	,[ '10K',      29348 ]
			 	,[ '15K',      29349 ]
			 	]}
			]
			,{ 'name'=> '42k', 'race' => 17232, 'bracketID' => 169240, 'intervals' => [
			 	 [ 'complete', 29350 ]
			 	,[ '10K',      29351 ]
			 	,[ '15K',      29352 ]
			 	,[ '21K',      29353 ]
			 	,[ '25K',      29354 ]
			 	,[ '32K',      29742 ]
			 	,[ '35K',      29792 ]
			 	]}
		}
};
# MSD2014 42k, 25K -- raceID=17232&bracketID=169240&intervalID=29354
# MSD2014 42k, 21K -- raceID=17232&bracketID=169240&intervalID=29353
# MSD2014 42k, 15K -- raceID=17232&bracketID=169240&intervalID=29352
# MSD2014 42k, 10K -- raceID=17232&bracketID=169240&intervalID=29351
# MSD2014 42k, complete -- raceID=17232&bracketID=169240&intervalID=29350
# 
# MSD2014 21k, 15K -- raceID=17231&bracketID=169212&intervalID=29349
# MSD2014 21k, 10K -- raceID=17231&bracketID=169212&intervalID=29348
# MSD2014 10k, -- raceID=17231&bracketID=169212&intervalID=29347
# MSD2014 10k, -- raceID=17230   bracketID=169184   intervalID=29346
#
# MSD2015 42k, 35K -- raceID=30947&bracketID=317833&intervalID=62512
# MSD2015 42k, 32.2K -- raceID=30947&bracketID=317833&intervalID=62446
# MSD2015 42k, 25K -- raceID=30947&bracketID=317833&intervalID=62445
# MSD2015 42k, 21.1k -- raceID=30947   bracketID=317833   intervalID=62444
# MSD2015 42k, 14.8k -- raceID=30947   bracketID=317833   intervalID=62443
# MSD2015 42k, 11k -- raceID=30947  bracketID=317833  intervalID=62442
# MSD2015 42k, complete -- raceID=30947  bracketID=317833  intervalID=60021
# MSD2015 21k, 14.8K -- raceID=30946  bracketID=317830  intervalID=62426
# MSD2015 21k, 11K -- raceID=30946   bracketID=317830   intervalID=62425
# MSD2015 21k, complete -- raceID=30946   bracketID=317830   intervalID=60020
# MSD2015 10k, overall -- event-13311; raceID=30945 bracketID=317827 intervalID=60019


my $sEventName='';
$sEventName=$optctl->{'event_name'}
	if ( exists($optctl->{'event_name'}) ) ;
die "No se conoce evento:[$sEventName]."	
	unless(exists($rEvents->{$sEventName}));



my $sOutFile=$sEventName . ".csv";

open OUT, ">:utf8", $sOutFile
	or die "No se pudo abrir archivo [$sOutFile] para escritura. $!";

print OUT join(';'
	,("race", "interval", "entryID", "Rank", "Name", "Bib", "GunTime", "Pace", "Hometown", "Age", "Sex", "Division", "DivRank", "GunMins"))
	,"\n";

my $re=$rEvents->{$sEventName};
my $sEvent=$re->{'event'};

foreach my $race (@{$re->{'races'}}) {
	# $race=$re->{'races'}->[0];
	my ($sRaceName, $sRace, $sBracketID, $nStart, $nLength);

	$sRaceName=$race->{'name'};
	$sRace=$race->{'race'};
	$sBracketID=$race->{'bracketID'};
	
	&{$::debug}("race: %s", Dumper($race)) if($::debugf);

	foreach my $inter (@{$race->{'intervals'}}) {
		# $sIntervalID=$race->{'intervalID'};
		&{$::debug}("inter: %s", Dumper($inter)) if($::debugf);
		my $sIntervalName=$inter->[0];
		my $sIntervalID=$inter->[1];

		$nStart=0;
		$nLength=100;
		my $nMax=1;


		while( $nStart < $nMax) {
			my $sText=GetChronotrackPage($sEvent, $sRace, $sBracketID, $sIntervalID, $nStart, $nLength);
			&{$::debug}("sText/1:[%s]...", substr($sText,0,256));
			
			$sText=BslashU2UTF($sText);
			&{$::debug}("sText/2:[%s]...", substr($sText,0,256));

			do {
				$sText=~s/^results_grid\d+\(//;
				my $res = ParseHash(\$sText);
				&{$::debug}("res: %s", Dumper($res)) if($::debugf);

				my $iTotalRecords=$res->{'iTotalRecords'};		
				&{$::debug}("iTotalRecords/1:[%s]", $iTotalRecords);
				$nMax=$iTotalRecords
					if($nMax<$iTotalRecords);

				foreach my $r (@{$res->{'aaData'}}) {
					my $t = join(';'
						,$sRaceName
						,$sIntervalName
						,Na($r->[0] )
						,Na($r->[1] )
						,QNa($r->[2] )
						,Na($r->[3] )
						,Na($r->[4] )
						,Na($r->[5] )
						,QNa($r->[6] )
						,Na($r->[7] )
						,Na($r->[8] )
						,QNa($r->[9] )
						,Na($r->[10] ) 
						,Na(Time2Mins($r->[4]))
						);
					print OUT $t, "\n";
					select((select(OUT), $| = 1)[0]);
				}
				&{$::debug}("sText[200]:[%s]", substr($sText,0,200));
				$sText=~s/^\);//;
			} while (length($sText));
			$nStart+=$nLength;
			sleep(2);
		}
	}
}



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

sub BslashU2UTF($)
{
	my ($s)=@_;
	my $ret='';
	
	# &{$::debug}("BslashU2UTF( %s )", join(' ', map( (defined($_)?"[$_]":'<undef>'), @_)));

	# Cuerpo de Funcion
	&{$::debug}("is_utf8(s)/1:[%s]", utf8::is_utf8($s));

	$ret=$s;
	$ret=~s/\\u00[0-9a-f][0-9a-f]/~/g;
	
	if ('') {
	$s=~s/\\u00a0/Â/g;
	$s=~s/\\u00aa/ª/g;

	$s=~s/\\u00b4/´/g;

	$s=~s/\\u00c0/À/g;
	$s=~s/\\u00c1/Á/g;
	$s=~s/\\u00c2/Â/g;
	$s=~s/\\u00c3/Ã/g;
	$s=~s/\\u00c4/Ä/g;
	$s=~s/\\u00c5/Å/g;
	$s=~s/\\u00c6/Æ/g;
	$s=~s/\\u00c7/Ç/g;
	$s=~s/\\u00c8/È/g;
	$s=~s/\\u00c9/É/g;
	$s=~s/\\u00ca/Ê/g;
	$s=~s/\\u00cb/Ë/g;
	$s=~s/\\u00cc/Ì/g;
	$s=~s/\\u00ce/Î/g;

	$s=~s/\\u00d1/Ñ/g;
	$s=~s/\\u00d2/Ò/g;
	$s=~s/\\u00d3/Ó/g;
	$s=~s/\\u00d4/Ô/g;
	$s=~s/\\u00d5/Õ/g;
	$s=~s/\\u00d6/Ö/g;
	$s=~s/\\u00d9/Ù/g;
	$s=~s/\\u00da/Ú/g;
	$s=~s/\\u00db/Û/g;
	$s=~s/\\u00dc/Ü/g;

	$s=~s/\\u00e0/à/g;
	$s=~s/\\u00e1/á/g;
	$s=~s/\\u00e2/â/g;
	$s=~s/\\u00e3/ã/g;
	$s=~s/\\u00e4/ä/g;
	$s=~s/\\u00e5/å/g;
	$s=~s/\\u00e6/æ/g;
	$s=~s/\\u00e7/ç/g;
	$s=~s/\\u00e8/è/g;
	$s=~s/\\u00e9/é/g;
	$s=~s/\\u00ea/ê/g;
	$s=~s/\\u00eb/ë/g;
	$s=~s/\\u00ec/ì/g;
	$s=~s/\\u00ed/í/g;
	$s=~s/\\u00ee/î/g;
	$s=~s/\\u00ef/ï/g;

	$s=~s/\\u00f1/ñ/g;
	$s=~s/\\u00f2/ò/g;
	$s=~s/\\u00f3/ó/g;
	$s=~s/\\u00f4/ô/g;
	$s=~s/\\u00f5/õ/g;
	$s=~s/\\u00f6/ö/g;
	$s=~s/\\u00f9/ù/g;
	$s=~s/\\u00fa/ú/g;
	$s=~s/\\u00fb/û/g;
	$s=~s/\\u00fc/ü/g;

	&{$::debug}("is_utf8(s)/2:[%s]", utf8::is_utf8($s));

	$ret=encode_utf8($s);
	&{$::debug}("is_utf8(ret)/1:[%s]", utf8::is_utf8($ret));
	}
		
	# &{$::debug}("BslashU2UTF()->[%s]", $ret);
	return $ret;
}


sub GetChronotrackPage($$$$$$)
{
	my ($sEvent, $sRace, $sBracketID, $sIntervalID, $nStart, $nLength)=@_;
	my $ret='';
	
	&{$::debug}("GetChronotrackPage( %s )", join(' ', map( (defined($_)?"[$_]":'<undef>'), @_)));

	# Cuerpo de Funcion
	my $sEcho=5;
	my $sUrl="https://results.chronotrack.com/embed/results/results-grid"
	."?callback=results_grid8365592"
	."&sEcho=${sEcho}"
	."&iColumns=11&sColumns="
	."&iDisplayStart=${nStart}&iDisplayLength=${nLength}"
	."&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4"
	."&mDataProp_5=5&mDataProp_6=6&mDataProp_7=7&mDataProp_8=8&mDataProp_9=9"
	."&mDataProp_10=10"
	."&userID=&lc=en"
	."&raceID=${sRace}"
	."&bracketID=${sBracketID}"
	."&intervalID=${sIntervalID}"
	."&entryID=&eventID=${sEvent}"
	."&eventTag=event-${sEvent}"
	."&oemID=www.chronotrack.com"
	."&userID=630456146&genID=8365592"
	."&x=1459875822772&_=1459875822776";

	my $sCookie='Cookie: _gig_llp=facebook; _gig_llu=Pablo; hsfirstvisit=https%3A%2F%2Fwww.chronotrack.com%2Fprivacy-policy%2F|https%3A%2F%2Fapi.chronotrack.com%2Fdev%2Fapp%2Fterms|1457363483828; chronotrack_secure_sid=4faj1mdhorg52gk18srqi199a5; CT=0kaq0bsal83e0majni0qv77af2; CT_QA=4s0vu7763vd79k7b0l6u67m9s4; CT_LANG=en; __utma=38466033.630456146.1457363483.1459869431.1459875974.4; __utmc=38466033; __utmz=38466033.1457363483.1.1.utmcsr=api.chronotrack.com|utmccn=(referral)|utmcmd=referral|utmcct=/dev/app/terms; _ga=GA1.2.630456146.1457363483; __hstc=46660728.429f965715707880aaf329225e9a7a07.1457363483831.1459869432187.1459875975860.4; __hssrc=1; hubspotutk=429f965715707880aaf329225e9a7a07; CT_ACCOUNT_ID=11324146; _gat_UA-34134613-4=1; _ga=GA1.3.389360205.1457362544';

	my $sCommand=qq{curl "$sUrl" }
	."	-H 'Accept: text/javascript, application/javascript, application/ecmascript, application/x-ecmascript, */*; q=0.01' "
	."	-H 'X-NewRelic-ID: Vg8EVlRbGwIFVFhRBwcB' "
	."	-H 'Referer: https://results.chronotrack.com/event/results/event/event-20591' "
	."	-H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.110 Safari/537.36' "
	."	-H 'X-Requested-With: XMLHttpRequest' "
	."	-H 'Accept-Encoding: gzip, deflate, sdch' "
	."	-H 'Accept-Language: es-419,es;q=0.8,de;q=0.6,en;q=0.4,ru;q=0.2' "
	.qq{	-H "${sCookie}" }
	."	-H 'Connection: keep-alive' "
	."	 --compressed";
	&{$::debug}("sCommand:[%s]", $sCommand);

	my $sOutput=`$sCommand`;
	
	$ret=$sOutput;
	
	&{$::debug}("GetChronotrackPage()->[%s]", $ret);
	return $ret;
}



