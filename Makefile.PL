require 5.004_04;

use ExtUtils::MakeMaker;

WriteMakefile(
	NAME		=> 'String::Approx',
	VERSION_FROM	=> 'Approx.pm',
	OBJECT		=> 'Approx.o apse.o',
#	CCFLAGS		=> '-DAPSE_DEBUGGING',
	dist		=> { 'COMPRESS' => 'gzip' }
);
