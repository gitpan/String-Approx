use String::Approx qw(asubstitute);

chdir('t') or die "could not chdir to 't'";

require 'util';

print "1..10\n";

# test 1

open(WORDS, 'words') or die "could not find words";

t(
  [qw(
      ap(peal)
      dis(pel)
      (erl)angen
      hy(per)bola
      m(erl)in
      (parl)ance
      (pearl)
      (per)k
      su(per)appeal
      su(per)lative
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
      hy(per)bola
      m(erl)in
      (parl)ance
      (per)k
      su(per)appeal
      su(per)lative
   )],
  [asubstitute('perl', '($&)', ['I0'], <WORDS>)]);
print "ok 2\n";

close(WORDS);

# test 3: like 1 but no deletions allowed

open(WORDS, 'words') or die "could not find 'words'";

t(
  [qw(
      a(ppeal)
      hy(perb)ola
      m(erl)in
      (parl)ance
      (pearl)
      (perk)
      su(pera)ppeal
      su(perl)ative
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
      su(per)lative
   )],
  [asubstitute('perl', '($&)', ['S0'], <WORDS>)]);
print "ok 4\n";

close(WORDS);

# test 5: 2-differences

open(WORDS, 'words') or die;

t(
  [qw(
      ab(er)rant
      acc(el)erate
      ap(pe)al
      dis(pe)l
      (er)langen
      f(el)icity
      gibb(er)ish
      hy(pe)rbola
      it(er)ate
      l(eger)demain
      m(er)lin
      m(er)maid
      oatm(eal)
      (par)k
      (par)lance
      Pea(rl)
      (pe)arl
      (pe)rk
      (pe)tal
      su(pe)rappeal
      su(pe)rlative
      sup(pl)e
      twi(rl)
      z(eal)ous
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
      hy(per)bola
      m(erl)in
      (parl)ance
      (Pearl)
      (pearl)
      (per)k
      su(per)appeal
      su(per)lative
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
      hy(per)bola
      m(erl)in
      (parl)ance
      (Pearl)
      (pearl)
      (per)k
      su(per)ap(peal)
      su(per)lative
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
      hy(hy:per:bola)bola
      m(m:erl:in)in
      (:parl:ance)ance
      (:pearl:)
      (:per:k)k
      su(su:per:appeal)appeal
      su(su:per:lative)lative
   )],
  [asubstitute('perl', q(($`:$&:$')), map {chomp;$_} <WORDS>)]);
print "ok 8\n";

close(WORDS);

# test 9: test for undefined input

undef $_;
eval 'asubstitute("foo","bar")';
print 'not ' unless ($@ =~ /what are you substituting/);
print "ok 9\n";
$_ = 'foo'; # anything defined so later tests do not fret

# test 10: test fuzzier subsitution.

open(WORDS, 'words') or die;

t(
  [qw(
      ab(ab:er:rant)rant
      acc(acc:el:erate)erate
      ap(ap:pe:al)al
      dis(dis:pe:l)l
      (:er:langen)langen
      f(f:el:icity)icity
      gibb(gibb:er:ish)ish
      hy(hy:pe:rbola)rbola
      it(it:er:ate)ate
      l(l:eger:demain)demain
      m(m:er:lin)lin
      m(m:er:maid)maid
      oatm(oatm:eal:)
      (:par:k)k
      (:par:lance)lance
      Pea(Pea:rl:)
      (:pe:arl)arl
      (:pe:rk)rk
      (:pe:tal)tal
      su(su:pe:rappeal)rappeal
      su(su:pe:rlative)rlative
      sup(sup:pl:e)e
      twi(twi:rl:)
      z(z:eal:ous)ous
   )],
  [asubstitute('perl', q(($`:$&:$')), [q(2)], map {chomp;$_} <WORDS>)]);
print "ok 10\n";

close(WORDS);

# eof
