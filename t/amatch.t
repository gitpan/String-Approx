use String::Approx 'amatch';

chdir('t') or die "could not chdir to 't'";

require 't'; # har har

print "1..6\n";

# test 1

open(WORDS, 'words') or die "could not find 'words'";

t(
  [qw(
      appeal
      dispel
      erlangen
      hyperbola
      merlin
      parlance
      pearl
      perk
      superappeal
      superlative
     )],
  [amatch('perl', <WORDS>)]);
print "ok 1\n";

close(WORDS);

# test 2: same as 1 but no insertions allowed

open(WORDS, 'words') or die;

t(
  [qw(
      appeal
      dispel
      erlangen
      hyperbola
      merlin
      parlance
      perk
      superappeal
      superlative
     )],
  [amatch('perl', ['I0'], <WORDS>)]);
print "ok 2\n";

close(WORDS);

# test 3: same as 1 but no deletions allowed

open(WORDS, 'words') or die;

t(
  [qw(
      appeal
      parlance
      pearl
      superappeal
      superlative
     )],
  [amatch('perl', ['D0'], <WORDS>)]);
print "ok 3\n";

close(WORDS);

# test 4: same as 1 but no substitutions allowed

open(WORDS, 'words') or die;

t(
  [qw(
      dispel
      erlangen
      hyperbola
      merlin
      pearl
      perk
      superappeal
      superlative
     )],
  [amatch('perl', ['S0'], <WORDS>)]);
print "ok 4\n";

close(WORDS);

# test 5: 2-differences

open(WORDS, 'words') or die;

t(
  [qw(
      aberrant
      accelerate
      appeal
      dispel
      erlangen
      felicity
      gibberish
      hyperbola
      iterate
      legerdemain
      merlin
      mermaid
      oatmeal
      park
      parlance
      Pearl
      pearl
      perk
      petal
      superappeal
      superlative
      supple
      twirl
      zealous
     )],
  [amatch('perl', [2], <WORDS>)]);
print "ok 5\n";

close(WORDS);

# test 6: i(gnore case)

open(WORDS, 'words') or die;

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
  [amatch('perl', ['i'], <WORDS>)]);
print "ok 6\n";

close(WORDS);

# eof
