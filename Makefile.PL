require 5;

use ExtUtils::MakeMaker;

sub MY::postamble {
    '
bench:
	$(PERL) -Iblib bench_run

    ';
}

open(VERSION, "VERSION") and
    chomp($version = <VERSION>) and
    close(VERSION);
die "Version undefined: $!\n" unless defined $version;
die "Version $version illegal\n" unless $version > 0;

use Cwd;

my $cwd = getcwd();

die "This directory ($cwd)\ndoes not look like version $version.\n"
    unless $cwd =~ /\Q$version\E$/;

if ( -M "Approx.pm" > -M "VERSION" or -M "Approx.pm" > -M "Makefile.PL" )  {
    print "Updating Approx.pm to version $version\n";
    local($^I, @ARGV) = ('.bak', 'Approx.pm');
    while (<>) {
	s/^(Version|\$VERSION\s*=)\s*(?:\d.+)([.;])$/$1 $version$2/;
	print;
	close ARGV if eof;
    }
}

WriteMakefile(
    'NAME'	=> 'String::Approx',
    'VERSION'	=> $version,
    'dist'	=> { 'COMPRESS' => 'gzip' }
);
