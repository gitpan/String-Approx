use String::Approx 'amatch';

chdir('t') or die "could not chdir to 't'";

require 't'; # har har

print "1..12\n";

# String::Approx::debug(1);

# test 1

open(WORDS, 'words') or die "could not find words";

my @words = <WORDS>;

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
  [amatch('perl', @words)]);
print "ok 1\n";

# test 2: same as 1 but no insertions allowed

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
  [amatch('perl', ['I0'], @words)]);
print "ok 2\n";

# test 3: same as 1 but no deletions allowed

t(
  [qw(
      appeal
      hyperbola
      merlin
      parlance
      pearl
      perk
      superappeal
      superlative
     )],
  [amatch('perl', ['D0'], @words)]);
print "ok 3\n";

# test 4: same as 1 but no substitutions allowed

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
  [amatch('perl', ['S0'], @words)]);
print "ok 4\n";

# test 5: 2-differences

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
  [amatch('perl', [2], @words)]);
print "ok 5\n";

# test 6: i(gnore case)

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
  [amatch('perl', ['i'], @words)]);
print "ok 6\n";

# test 7: test for undefined input

undef $_;
eval 'amatch("foo")';
print 'not ' unless ($@ =~ /what are you matching against/);
print "ok 7\n";
$_ = 'foo'; # anything defined so later tests do not fret

# test 8: test just for acceptance of a very long pattern

amatch("abcdefghij" x 10);
print "ok 8\n";

# test 9: test long pattern matching

$_ = 'xyz' x 10 . 'abc0defghijabc1defghij' . 'zyx' x 10;
print 'not ' unless amatch('abcdefghij' x 2);
print "ok 9\n";

# test 10: test long pattern NOT matching
# NOTE: this shows the weirdness of long pattern matching:
# compare this with the test #9.  You will notice that
# the only difference is that the test fails if both the
# mutations are in the same partition but succeeds when
# mutations are in different partitions.

$_ = 'xyz' x 10 . 'abc0de1fghijabcdefghij' . 'zyx' x 10;
print 'not ' if amatch('abcdefghij' x 2);
print "ok 10\n";

# test 11: test long pattern both matching and not matching
# Thanks to Alberto Fontaneda <alberfon@ctv.es>
# for this test case and also thanks to Dmitrij Frishman
# <frishman@mips.biochem.mpg.de> for testing this test.
{
my @l = ('perl warks fiine','parl works fine', 'perl worrs', 'perl warkss');
my @m = amatch('perl works fin', [2] , @l);
print 'not ' if not @m == 2 or
                $m[0] ne 'perl warks fiine' or
                $m[1] ne 'parl works fine';
print "ok 11\n";
#print "m = (@{[join(':',@m)]})\n";
}

# test 12: test stingy matching.

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
  [amatch('perl', ['?'], @words)]);

print "ok 12\n";

# eof
