require 5;

use ExtUtils::MakeMaker;

sub MY::postamble {
    '
bench: 
	$(PERL) -Iblib bench_run
    ';
}

WriteMakefile(
    'NAME'	=> 'String::Approx',
    'VERSION'	=> 2.4,
    'dist'	=> { 'COMPRESS' => 'gzip' }
);
