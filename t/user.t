# User-supplied test cases.
# (These *were* bugs :-)

use String::Approx 'amatch';

chdir('t') or die "could not chdir to 't'";

require 'util';

local $^W = 1;

print "1..21\n";

# test 1: test long pattern both matching and not matching
# Thanks to Alberto Fontaneda <alberfon@ctv.es>
# for this test case and also thanks to Dmitrij Frishman
# <frishman@mips.biochem.mpg.de> for testing this test.
{
my @l = ('perl warks fiine','parl works fine', 'perl worrs', 'perl warkss');
my @m = amatch('perl works fin', [2] , @l);
print 'not ' if not @m == 2 or
                $m[0] ne 'perl warks fiine' or
                $m[1] ne 'parl works fine';
print "ok 1\n";
#print "m = (@{[join(':',@m)]})\n";
}

# test 2: Slaven Rezic <eserte@cs.tu-berlin.de>

{
my @w=('one hundred','two hundred','three hundred','bahnhofstr. (koepenick)');
my @m=amatch('bahnhofstr. ', ['i',3], @w);
t(['bahnhofstr. (koepenick)'],[@m]);
print "ok 2\n";
}

# tests 3-6: Greg Ward <greg@bic.mni.mcgill.ca>

print "not " unless
	amatch('mcdonald', 'macdonald') and
	amatch('macdonald', 'mcdonald');
print "ok 3\n";

print "not " unless
	amatch('mcdonald', ['I0'], 'macdonald'); 
print "ok 4\n";

print "not " if
	amatch('mcdonald', ['I0'], 'mcdonaald') or
	amatch('mcdonald', ['I1'], 'mcdonaaald');
print "ok 5\n";

print "not " unless
	amatch('mcdonald', ['1I1'], 'mcdonaald') and
	amatch('mcdonald', ['2I2'], 'mcdonaaald');
print "ok 6\n";

# test 7: Kevin Greiner <kgreiner@geosys.com>

@IN = ("AK_ANCHORAGE A-7 NW","AK A ANCHORAGE B-8 NE");
$Title = "AK_ANCHORAGE A-7 NE";
print "not " unless amatch($Title, @IN);
print "ok 7\n";

# test 8: Ricky Houghton <ricky.houghton@cs.cmu.edu>

@names = ("madeleine albright","william clinton");
@matches = amatch("madeleine albriqhl",@names);
print "not "
	unless @matches == 1 and
	$matches[0] eq "madeleine albright";
print "ok 8\n";

# test 9: Jared August <rudeop@skapunx.net>

print "not " unless amatch("Dopeman (Remix)",["i","50%"],"Dopeman (Remix)");
print "ok 9\n";

# tests 10-16: Steve A. Chervitz <sac@genome.Stanford.edu>

# Short vs. Long behaved differently than Long vs. Short.

# s1 and s1_1 are identical except for an extra extension at end of s1.

$s1   = "MSRTGHGGLMPVNGLGFPPQNVARVVVWECLNEHSRWRPYTATVCHHIENVLKEDARGSVVLGQVDAQ".
    "LVPYIIDLQSMHQFRQDTGTMRPVRRNFYDPSSAPGKGIVWEWENDGGAWTAYDMDICITIQNAYEKQHPWLW_GBH";

$s1_1 = "MSRPGHGGLMPVNGLGFPPQNVARVVVWECLNEHSRWRPYTATVCHHIENVLKEDARGSVVLGQVDAQ".
    "LVPYIIDLQSMHQFRQDTGTMRPVRRNFYDPSSAPGKGIVWEWENDGGAWTAYDMDICITIQNAYEKQHPWLW";

if(amatch($s1, ['5%'], $s1_1)) {  # this failed to match
    #
} else {
    print "not ";
}
print "ok 10\n";

if(amatch($s1_1, ['5%'], $s1)) {
    #
} else {
    print "not ";
}
print "ok 11\n";

# s1_1 vs. s1: (attempting to disallow insertions).

if(amatch($s1_1, ['5%','I0'], $s1)) {  
    #
} else {
    print "not ";
}
print "ok 12\n";

#-----------------------------------------------------------------------
# Position dependency of approximate matching.

# There is a position dependency for matching. If two strings differ
# at two neighboring (or very close) positions, they will not match
# with approximation.  If the differences are well-separated, they
# will match with approximation.

$s2   = "DLSSLGFCYLIYFNSMSQMNRQTRRRRRLRRRLDLAYPLTVGSIPKSQSWPVGASSGQPCSCQQCLLVNSTRAVSN".
    "VILASQRRKVPPAPPLPPPPPPGGPPGALAVRPSATFTGAALWAAPAAGPAEPAPPPGAPPRSPGAPGGARTPGQNNLNR".
    "PGPQRTTSVSARASIPPGVPALPVKNLNGTGPVHPALAGMTGILLCAAGLPVCLTRAPKPILHPPPVSKSDVKPVPGVPG".
    "VCRKTKKKHLKKSKNPEDVVRRYMQKVKNPPDEDCTICMERLVTASGYEGVLRHKGVRPELVGRLGRCGHMYHLLCLVAMY".
    "SNGNKDGSLQCPTCKAIYGEKTGTQPPGKMEFHLIPHSLPGFPDTQTIRIVYDIPTGIQGPEHPNPGKKFTARGFPRHCYL".
    "PNNEKGRKVLRLLITAWERRLIFTIGTSNTTGESDTVVWNEIHHKTEFGSNLTGHGYPDASYLDNVLAELTAQGVSEAAGKA";

# s2_1 has two nearby substitutions relative to s2 indicated with '_'

$s2_1  = "DLSSLGFCYL_YFNSMSQMN_QTRRRRRLRRRLDLAYPLTVGSIPKSQSWPVGASSGQPCSCQQCLLVNSTRAVSN".
    "VILASQRRKVPPAPPLPPPPPPGGPPGALAVRPSATFTGAALWAAPAAGPAEPAPPPGAPPRSPGAPGGARTPGQNNLNR".
    "PGPQRTTSVSARASIPPGVPALPVKNLNGTGPVHPALAGMTGILLCAAGLPVCLTRAPKPILHPPPVSKSDVKPVPGVPG".
    "VCRKTKKKHLKKSKNPEDVVRRYMQKVKNPPDEDCTICMERLVTASGYEGVLRHKGVRPELVGRLGRCGHMYHLLCLVAMY".
    "SNGNKDGSLQCPTCKAIYGEKTGTQPPGKMEFHLIPHSLPGFPDTQTIRIVYDIPTGIQGPEHPNPGKKFTARGFPRHCYL".
    "PNNEKGRKVLRLLITAWERRLIFTIGTSNTTGESDTVVWNEIHHKTEFGSNLTGHGYPDASYLDNVLAELTAQGVSEAAGKA";


# s2_2 has two far apart substitutions relative to s2 indicated with '_'

$s2_2  = "DLSSLGFC_LIYFNSMSQMNRQTRRRRRLRRRLDLAYPLTVGSIPKSQSWPVGASSGQPCSCQQCLLVNSTRAVSN".
    "VILASQRRKVPPAPPLPPPPPPGGPPGALAVRPSATFTGAALWAAPAAGPAEPAPPPGAPPRSPGAPGGARTPGQNNLNR".
    "PGPQRTTSVSARASIPPGVPALPVKNLNGTGPVHPALAGMTGILLCAAGLPVCLTRAPKPILHPPPVSKSDVKPVPGVPG".
    "VCRKTKKKHLKKSKNPEDVVRRYMQKVKNPPDEDCTICMERLVTASGYEGVLRHKGVRPELVGRLGRCGHMYHLLCLVAMY".
    "SNGNKDGSLQCPTCKAIYGEKTGTQPPGKMEFHLIPHSLPGFPDTQTIRIVYDIPTGIQGPEHPNPGKKFTARGFPRHCYL".
    "PNNEKGRKVLRLLITAWERRLIFTIGTSNTTGESDTVVWNEIHHKTEFGSNLTG_GYPDASYLDNVLAELTAQGVSEAAGKA";


# s2 vs s2_1: (substitutions close together)

if(amatch($s2, [10], $s2_1)) {
    #
} else {
    print "not ";
}
print "ok 13\n";

# s2 vs s2_2: (substitutions far apart)

if(amatch($s2, [10], $s2_2)) {
    #
} else {
    print "not ";
}
print "ok 14\n";

#-----------------------------------------------------------------------
# Difference in behavior of % differences versus absolute number of
# differences.

$s3 =  "MNIFEMLRIDEGLRLKIYKDTEGYYTIGIGHLLTKSPSLNAAKSELDKAIGRNCNGVITKDEAEKLFNQDVDAAVRG".
    "ILRNAKLKPVYDSLDAVRRCALINMVFGMGETGVAGFTNSLRMLQQKRWDEAAVNLAKSRWYNQTPNRAKRVITTFRTGT".
    "WDAYKNL";

# s3_1 contains two substitutions '_' and one deletion relative to s3.
$s3_1 = "MNIFEMLRIDEGLRLKIYKDTEGYYTIGIGHLLTKSPSLNAAKSELDKAIGRN_NGVITKDEAEKLFNQDVDAVRG".
    "ILRNAKLKPVYDSLDAVRRCALINMVF_MGETGVAGFTNSLRMLQQKRWDEAAVNLAKSRWYNQTPNRAKRVITTFRTGT".
    "WDAYKNL";

# s3 vs s3_1: (matching with 10% differences)

if(amatch($s3, ['10%'], $s3_1)) { 
    #
} else {
    print "not ";
}
print "ok 15\n";

# s3 vs s3_1: (matching with 10 differences)

if(amatch($s3, ['10'], $s3_1)) {    
    #
} else {
    print "not ";
}
print "ok 16\n";

# test 17: Bob J.A. Schijvenaars <schijvenaars@mi.fgg.eur.nl>

@gloslist = ('computer', 'computermonitorsalesman');
@matches = amatch('computers', [1,'g'], @gloslist);
$a = '';
for (@matches) {
   $a .= "|$_|";
}
@matches = amatch('computers', [2,'g'], @gloslist);
$b = '';
for (@matches) {
   $b .= "|$_|";
}

print "not " unless $a eq $b and $a eq "|computer||computermonitorsalesman|";
print "ok 17\n";

# test 18: Rick Wise <rwise@lcc.com>

print "not " unless amatch('abc', [10], 'abd');
print "ok 18\n";

# tests 19-21: Ilya Sandler <sandler@etak.com>

$_="ABCDEF";
print "not " if amatch("ABCDEF","VWXYZ");
print "ok 19\n";

print "not " unless amatch("BURTONUPONTRENT",['5'], "BURTONONTRENT");
print "ok 20\n";

print "not " unless amatch("BURTONONTRENT",['5'], "BURTONUPONTRENT");
print "ok 21\n";

# eof

