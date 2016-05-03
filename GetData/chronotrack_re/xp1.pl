#!/usr/bin/perl -w

=head1 		Copyright SQL*TECHNOLOGY 2016

=head1 NOMBRE

xp2.pl - 

=head1 SINOPSIS

   xp2.pl [switches]
      --help         Obtener ayuda
      --debug        Mostrar mensajes de debug (STDERR)
      --trace        Guardar mensajes de debug en xp2.pl.trc
      --sqltech=dir  Directorio de herramientas (SQLTECHHOME)

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

sub ParseQVal($);
sub ParseCsv($);
sub ParseTuple($);
sub ParseVal($);
sub ParseHash($);



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


if ('') {
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
}

#
#
#
#

if (1) {
open IN, "<:utf8", $sInFile
	or die "No se pudo abrir archivo [$sInFile] para lectura. $!";

open OUT, ">:utf8", $sOutFile
	or die "No se pudo abrir archivo [$sOutFile] para escritura. $!";

print OUT join(';'
	,("entryID", "Rank", "Name", "Bib", "GunTime", "Pace", "Hometown", "Age", "Sex", "Division", "DivRank", "GunMins"))
	,"\n";
	
while(<IN>)
{
	chomp();
	next if /^#/;
	my $sText=$_;

	do {
		&{$::debug}("sText[200]/1:[%s]", substr($sText,0,200));
		$sText=~s/^results_grid\d+\(//;
		my $res = ParseHash(\$sText);
		&{$::debug}("res: %s", Dumper($res)) if($::debugf);

		foreach my $r (@{$res->{'aaData'}}) {
			my $t = join(';'
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
}

close OUT;
close IN;
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


# ,["20634417","10802","Juana julia Catriñanco Donoso","19635","03:43:34","10:39","Chile, --","61","F","Damas 60 a 64 años","22"]


sub ParseHash($)
{
	my ($rStr)=@_;
	my $ret;
	
	# &{$::debug}("ParseHash( %s )", join(' ', map( (defined($_)?"<".substr(${$_}, 0, 32).">":'<undef>'), @_)));

	# Cuerpo de Funcion
	${$rStr} =~ s/^\s+//;
	if (substr(${$rStr}, 0,1) eq '{') {
		$ret={} unless defined($ret);
		
		substr(${$rStr}, 0, 1) ='';
		while (substr(${$rStr}, 0,1) ne '}') {
			my $k = ParseQVal($rStr);

			${$rStr} =~ s/^\s+//;
			if (substr(${$rStr}, 0,1) eq ':') {
				substr(${$rStr}, 0, 1) ='';
				my $v = ParseVal($rStr);
				if (defined($v)) {
					$ret->{$k}=$v;
				} else {
					die sprintf("Valor no encontrado: %s", substr(${$rStr},0,32));
				}
				${$rStr} =~ s/^\s+//;
			}
			${$rStr} =~ s/^\s+//;
			my $bComma=(substr(${$rStr}, 0,1) eq ',');
			substr(${$rStr}, 0,1)='' if ($bComma);
			${$rStr} =~ s/^\s+//;
		}
		substr(${$rStr}, 0,1)=''
			if(substr(${$rStr}, 0,1) eq '}');
	}
	
	# &{$::debug}("ParseHash()->[%s]", $ret);
	return $ret;
}


sub ParseTuple($)
{
	my ($rStr)=@_;
	my $ret;
	
	# &{$::debug}("ParseTuple( %s )", join(' ', map( (defined($_)?"<".substr(${$_}, 0, 32).">":'<undef>'), @_)));

	# Cuerpo de Funcion
	${$rStr} =~ s/^\s*(\[?)\s*//;
	# &{$::debug}("1:[%s]", $1);
	if (length($1)) {
		my $c = substr(${$rStr}, 0,1);
		if ($c eq ']') {
			$ret = [];
		} else {
			$ret = ParseCsv($rStr);
			# &{$::debug}("ret:%s", Dumper($ret));
		}
		${$rStr} =~ s/^\s*(\]?)\s*//;
		# &{$::debug}("1:[%s]", $1);
		# &{$::debug}("{rStr}:[%s]", ${$rStr});
	}
	# &{$::debug}("ParseTuple()->%s", Dumper($ret));
	return $ret;
}


sub ParseCsv($)
{
	my ($rStr)=@_;
	my $ret=[];
	
	# &{$::debug}("ParseCsv( %s )", join(' ', map( (defined($_)?"<".substr(${$_}, 0, 32).">":'<undef>'), @_)));

	# Cuerpo de Funcion
	my $bComma;
	${$rStr} =~ s/^\s+//;
	do {
		my $v = ParseVal($rStr);
		push @{$ret}, $v
			if (defined($v));
		${$rStr} =~ s/^\s*(,?)\s*//;
		#&{$::debug}("1:[%s]", $1);
		$bComma=(length($1));
		# &{$::debug}("bComma:[%s]", $bComma);
	} 	while ($bComma);
	
	# &{$::debug}("ParseCsv()->%s", Dumper($ret));
	return $ret;
}



# "20634417"
# "10802",
# "Juana julia Catri\u00f1anco Donoso"
# "03:43:34"
# .. "10:39","Chile, --","61","F","Damas 60 a 64 a\u00f1os","22"

sub ParseQVal($)
{
	my ($rStr)=@_;
	my $ret;
	
	# &{$::debug}("ParseQVal( %s )", join(' ', map( (defined($_)?"[$_]":'<undef>'), @_)));

	# Cuerpo de Funcion
	${$rStr} =~ s/^\s+//;
	if (substr(${$rStr}, 0,1) eq '"') {
		my $c=0;
		do { 
			$c = index(${$rStr}, '"', $c+1);
		} while(($c > 0) and (substr(${$rStr}, $c-1,1) eq '\\'));
		if ($c > -1) {
			$ret=substr(${$rStr}, 1, $c-1);
			substr(${$rStr}, 0, $c+1)='';
		}
	}
	# &{$::debug}("ParseQVal()->%s", defined($ret)?"[$ret]":'<undef>');
	return $ret;
}

sub ParseVal($)
{
	my ($rStr)=@_;
	my $ret;
	
	# &{$::debug}("ParseVal( %s )", join(' ', map( (defined($_)?"<".substr(${$_}, 0, 32).">":'<undef>'), @_)));

	# Cuerpo de Funcion
	${$rStr} =~ s/^\s+//;
	my $c = substr(${$rStr}, 0,1);
	if ($c eq '"') {
		$ret = ParseQVal($rStr);
	} elsif ($c eq '[') {
		$ret = ParseTuple($rStr);
	} elsif ($c eq '{') {
		$ret = ParseHash($rStr);
	} else  {
		# &{$::debug}("{rStr}:[%s]", ${$rStr});
		$ret='';
		my $bEsc='';
		my $n;
		do {
			${$rStr} =~ m/^([^,\}\]]+)/;
			# &{$::debug}("1:[%s]", $1);
			$n=length($1);
			# &{$::debug}("n:[%s]", $n);
			$bEsc=( substr($1, -1,1) eq '\\');
			# &{$::debug}("bEsc:[%s]", $bEsc);
			if ($bEsc) {
				$ret.=substr(${$rStr}, 0, $n-1) . substr(${$rStr}, $n, 1);
				$n+=1;
			} else {
				$ret.=substr(${$rStr}, 0, $n);
			}
			substr(${$rStr}, 0, $n)='';
		} while ($bEsc);
		$ret =~ s/\s+$//;
		# &{$::debug}("{rStr}:[%s]", ${$rStr});
	}
	# &{$::debug}("ParseVal()->%s", defined($ret)?"[$ret]":'<undef>');
	return $ret;
}

