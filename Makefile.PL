use ExtUtils::MakeMaker;

WriteMakefile(
	NAME		=> 'String::Approx',
	VERSION_FROM	=> 'Approx.pm',
	OBJECT		=> 'Approx.o apse.o',
#	CCFLAGS		=> '-DAPSE_DEBUGGING',
#	CCFLAGS		=> '-Wall',
	dist		=> { 'COMPRESS' => 'gzip' }
);
