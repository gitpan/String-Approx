use String::Approx 'asubstitute';

chdir('t') or die "could not chdir to 't'";

require 't'; # har har

print "1..10\n";

# test 1

open(WORDS, 'words') or die "could not find 'words'";

t(
  [qw(
      ap(peal)
      dis(pel)
      (erl)angen
      hy(perb)ola
      (merl)in
      (parl)ance
      (pearl)
      (perk)
      su(pera)ppeal
      su(perla)tive
   )],
  [asubstitute('perl', '($&)', <WORDS>)]);
print "ok 1\n";

close(WORDS);

# test 2: like 1 but no insertions allowed

open(WORDS, 'words') or die "could not find 'words'";

t(
  [qw(
      ap(peal)
      dis(pel)
      (erl)angen
      hy(perb)ola
      (merl)in
      (parl)ance
      (perk)
      su(pera)ppeal
      su(perla)tive
   )],
  [asubstitute('perl', '($&)', ['I0'], <WORDS>)]);
print "ok 2\n";

close(WORDS);

# test 3: like 1 but no deletions allowed

open(WORDS, 'words') or die "could not find 'words'";

t(
  [qw(
      ap(peal)
      hy(perb)ola
      (merl)in
      (parl)ance
      (pearl)
      (perk)
      su(pera)ppeal
      su(perla)tive
   )],
  [asubstitute('perl', '($&)', ['D0'], <WORDS>)]);
print "ok 3\n";

close(WORDS);

# test 4: like 1 but no substitutions allowed

open(WORDS, 'words') or die "could not find 'words'";

t(
  [qw(
      dis(pel)
      (erl)angen
      hy(per)bola
      m(erl)in
      (pearl)
      (per)k
      su(per)appeal
      su(perl)ative
   )],
  [asubstitute('perl', '($&)', ['S0'], <WORDS>)]);
print "ok 4\n";

close(WORDS);

# test 5: 2-differences

open(WORDS, 'words') or die;

t(
  [qw(
      a(berr)ant
      ac(cel)erate
      a(ppeal)
      di(spel)
      (erla)ngen
      (fel)icity
      gib(beri)sh
      h(yperb)ola
      i(tera)te
      le(gerd)emain
      (merli)n
      (merm)aid
      oat(meal)
      (park)
      (parla)nce
      (Pearl)
      (pearl)
      (perk)
      (petal)
      s(upera)ppeal
      s(uperla)tive
      su(ppl)e
      t(wirl)
      (zeal)ous
     )],
  [asubstitute('perl', '($&)', [2], <WORDS>)]);
print "ok 5\n";

close(WORDS);

# test 6: i(gnore case)

open(WORDS, 'words') or die;

t(
  [qw(
      ap(peal)
      dis(pel)
      (erl)angen
      hy(perb)ola
      (merl)in
      (parl)ance
      (Pearl)
      (pearl)
      (perk)
      su(pera)ppeal
      su(perla)tive
     )],
  [asubstitute('perl', '($&)', ['i'], <WORDS>)]);
print "ok 6\n";

close(WORDS);

# test 7: both i(gnore case) and g(lobally)

open(WORDS, 'words') or die;

t(
  [qw(
      ap(peal)
      dis(pel)
      (erl)angen
      hy(perb)ola
      (merl)in
      (parl)ance
      (Pearl)
      (pearl)
      (perk)
      su(pera)p(peal)
      su(perla)tive
     )],
  [asubstitute('perl', '($&)', ['ig'], <WORDS>)]);
print "ok 7\n";

close(WORDS);

# test 8: exercise all of $` $& $'

open(WORDS, 'words') or die;

t(
  [qw(
      ap(ap:peal:)
      dis(dis:pel:)
      (:erl:angen)angen
      hy(hy:perb:ola)ola
      (:merl:in)in
      (:parl:ance)ance
      (:pearl:)
      (:perk:)
      su(su:pera:ppeal)ppeal
      su(su:perla:tive)tive
   )],
  [asubstitute('perl', q(($`:$&:$')), map {chomp;$_} <WORDS>)]);
print "ok 8\n";

close(WORDS);

# test 9: test for undefined input

undef $_;
eval 'asubstitute("foo","bar")';
print 'not ' unless ($@ =~ /what are you matching against/);
print "ok 9\n";
$_ = 'foo'; # anything defined so later tests do not fret

# test 10: test for too long pattern

eval 'asubstitute("abcdefghijklmnopqrst" x 10,"")';
print 'not 'if ($@ =~ /too long pattern/);
print "ok 10\n";

# eof
