use String::Approx qw(amatch compat1);

chdir('t') or die "could not chdir to 't'";

require 't'; # har har

# test 1: test the v1 compatibility syntax with i(gnore case)

print "1..1\n";

open(WORDS, 'words') or die;

my @words = ();

while (<WORDS>) {
  push(@words, $_) if amatch('perl', 'i');
}

t(
  [qw(
      appeal
      dispel
      erlangen
      hyperbola
      merlin
      parlance
      Pearl
      pearl
      perk
      superappeal
      superlative
     )],
  [@words]);
print "ok 1\n";

close(WORDS);

# eof
