use String::Approx qw(asubstitute aregex);

chdir('t') or die "could not chdir to 't'";

require 't'; # har har

# String::Approx::debug(1);

print "1..12\n";

# test 1

open(WORDS, 'words') or die "could not find words";

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
      su(perl)ative
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
      su(perl)ative
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
      (erl)angen
      (fel)icity
      gib(beri)sh
      h(yperb)ola
      i(tera)te
      le(gerd)emain
      (merl)in
      (merm)aid
      oat(meal)
      (park)
      (parl)ance
      (Pearl)
      (pearl)
      (perk)
      (petal)
      s(upera)ppeal
      s(uperl)ative
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
      su(perl)ative
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
      su(perl)ative
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
      su(su:perl:ative)ative
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

# test 11: test fuzzier subsitution.

open(WORDS, 'words') or die;

t(
  [qw(
	a(a:berr:ant)ant
	ac(ac:cel:erate)erate
	a(a:ppeal:)
	di(di:spel:)
	(:erl:angen)angen
	(:fel:icity)icity
	gib(gib:beri:sh)sh
	h(h:yperb:ola)ola
	i(i:tera:te)te
	le(le:gerd:emain)emain
	(:merl:in)in
	(:merm:aid)aid
	oat(oat:meal:)
	(:park:)
	(:parl:ance)ance
	(:Pearl:)
	(:pearl:)
	(:perk:)
	(:petal:)
	s(s:upera:ppeal)ppeal
	s(s:uperl:ative)ative
	su(su:ppl:e)e
	t(t:wirl:)
	(:zeal:ous)ous
   )],
  [asubstitute('perl', q(($`:$&:$')), [q(2)], map {chomp;$_} <WORDS>)]);
print "ok 11\n";

close(WORDS);

# test 12: test stingy matching.

open(WORDS, 'words') or die;

t(
  [qw(
	ab(ab:er:rant)rant
	acc(acc:el:erate)erate
	a(a:ppeal:)
	dis(dis:pel:)
	(:erl:angen)angen
	f(f:el:icity)icity
	gibb(gibb:er:ish)ish
	hy(hy:per:bola)bola
	it(it:er:ate)ate
	leg(leg:er:demain)demain
	m(m:erl:in)in
	m(m:er:maid)maid
	oatm(oatm:eal:)
	(:par:k)k
	(:parl:ance)ance
	P(P:earl:)
	(:pearl:)
	(:per:k)k
	(:petal:)
	su(su:per:appeal)appeal
	su(su:perl:ative)ative
	su(su:ppl:e)e
	twi(twi:rl:)
	z(z:eal:ous)ous
   )],
  [asubstitute('perl', q(($`:$&:$')), [q(2?)], map {chomp;$_} <WORDS>)]);
print "ok 12\n";

close(WORDS);

# eof
