package String::Approx;

=head1 NAME

String::Approx - match and substitute approximately (aka fuzzy matching)

=head1 SYNOPSIS

	use String::Approx qw(amatch asubstitute);

=head1 DESCRIPTION

B<Approximate> is defined here as I<k-differences>.  One I<difference>
is an insertion, a deletion, or a substitution of one character.
The I<k> in the I<k-differences> is the maximum number of differences.

For example I<1-difference> means that a match is found if there is
one character too many (insertion) or one character missing (deletion)
or one character changed (substitution).  Those are I<exclusive or>s:
that is, I<not> one of each type of modification but I<exactly one>.

=head2 The default approximateness

The default approximateness is I<10 %> of the length of the
approximate pattern or I<at least 1>: I<0-differences> being the exact
matching which can be done very effectively using the usual Perl
function C<index()> or normal regular expression matching.

=head2 amatch

	use String::Approx qw(amatch);

	amatch("PATTERN");
	amatch("PATTERN", @LIST);
	amatch("PATTERN", [ @MODS ]);
	amatch("PATTERN", [ @MODS ], @LIST);

The PATTERN is B<a string>, not a regular expression.  The regular
expression metanotation (C<. ? * + {...,...} ( ) | [ ] ^ $ \w ...>)
will be understood as literal characters, that is, a C<*> means in
regex terms C<\*>, not I<"match 0 or more times">.

The LIST is the list of strings to match against the pattern.
If no LIST is given matches against C<$_>.

The MODS are the modifiers that tell how approximately to match.
See below for more detailed explanation.
B<NOTE>: The syntax really is C<[ @MODS ]>, the square
brackets C<[ ]> must be in there.  See below for examples.

In scalar context C<amatch()> returns the number of successful
substitutions.  In list context C<amatch()> returns the strings that
had substitutions.

Example:

	use String::Approx qw(amatch);

	open(WORDS, '/usr/dict/words') or die;

	while (<WORDS>) {
	    print if amatch('perl');
	}

or the same ignoring case:

	use String::Approx qw(amatch);

	open(WORDS, '/usr/dict/words') or die;

	while (<WORDS>) {
	    print if amatch('perl', ['i']);
	}

=head2 asubstitute

	use String::Approx qw(asubstitute);

	asubstitute("PATTERN", "SUBSTITUTION");
	asubstitute("PATTERN", "SUBSTITUTION", @LIST);
	asubstitute("PATTERN", "SUBSTITUTION", [ @MODS ]);
	asubstitute("PATTERN", "SUBSTITUTION", [ @MODS ], @LIST);

The PATTERN is B<a string>, not a regular expression.  The regular
expression metanotation (C<. ? * + {...,...} ( ) | [ ] ^ $ \w ...>)
will be understood as literal characters, that is, a C<*> means in
regex terms C<\*>, not I<"match 0 or more times">.

Also the SUBSTITUTION is B<a string>, not a regular expression.  Well,
mostly.  I<Most of the> regular expression metanotation (C<.>, C<?>,
C<*>, C<+>, ...) will be not understood as literal characters, that
is, a C<*> means in regex terms C<\*>, not I<"match 0 or more times">.
The understood notations are

=over 8

=item	C<$`>

the part I<before> the approximate match

=item	C<$&>

the approximately matched part

=item	C<$'>

the part I<after> the approximate match

=back

The MODS are the modifiers that tell how approximately to match.
See below for more detailed explanation.
B<NOTE>: Yes, the syntax is really C<[ @MODS ]>, the square
brackets C<[ ]> must be in there.  See below for examples.

The LIST is the list of strings to substitute against the pattern.
If no LIST is given substitutes against C<$_>.

In scalar context C<asubstitute()> returns the number of successful
substitutions.  In list context C<asubstitute()> returns the strings
that had substitutions.

Examples:

	use String::Approx qw(asubstitute);

	open(WORDS, '/usr/dict/words') or die;
	while (<WORDS>) {
	    print if asubstitute('perl', '($&)');
	}

or the same ignoring case:

	use String::Approx qw(asubstitute);

	open(WORDS, '/usr/dict/words') or die;
	while (<WORDS>) {
	    print if asubstitute('perl', '($&)', [ 'i' ]);
	}

=head2 Modifiers

The MODS argument both in amatch() and asubstitute() is a list of
strings that control the matching of PATTERN.  The first two, B<i> and
B<g>, are the usual regular expression match/substitute modifiers, the
rest are special for approximate matching/substitution.

=over 8

=item	i

Match/Substitute ignoring case, case-insensitively.

=item	g

Substitute I<globally>, that is, all the approximate matches, not just
the first one.

=item	I<k>

The maximum number of differences.
For example 2.

=item	II<k>

The maximum number of insertions.
For example 'I2'.

=item	DI<k>

The maximum number of deletions.
For example 'D2'.

=item	SI<k>

The maximum number of substitutions.
For example 'S2'.

=item	I<k>%

The maximum relative number of differences.
For example '10%'.

=item	II<k>%

The maximum relative number of insertions.
For example 'I5%'.

=item	DI<k>%

The maximum relative number of deletions.
For example 'D5%'.

=item	SI<k>%

The maximum relative number of substitutions.
For example 'S5%'.

=back

I<The regular expression modifiers> C<o m s x> I<are> B<not supported>
because their definitions for approximate matching are less than clear.

The relative number of differences is relative to the length of the
PATTERN, rounded up: if, for example, the PATTERN is C<'bouillabaise'>
and the MODS is C<['20%']> the I<k> becomes I<3>.

If you want to B<disable> a particular kind of difference you need
to explicitly set it to zero: for example C<'D0'> allows no deletions.

In case of conflicting definitions the later ones silently override,
for example:

	[2, 'I3', 'I1']

equals

	['I1', 'D2', 'S2']

=head1 EXAMPLES

The following examples assume the following template:

	use String::Approx qw(amatch asubstitute);

	open(WORDS, "/usr/dict/words") or die;
	while (<WORDS>) {
		# <---
	}

and the following examples just replace the above 'C<# E<lt>--->' line.

=head2 Matching from the C<$_>

=over 8

=item Match 'perl' with one difference

	print if amatch('perl');

The I<one difference> is automatically the result in this case because
first the rule of the I<10 %> of the length of the pattern ('C<perl>')
is used and then the I<at least 1> rule.

=item Match 'perl' with case ignored

	print if amatch('perl', [ 'i' ]);

The case is ignored in matching (C<i>).

=item Match 'perl' with one insertion

	print if amatch('perl', [ '0', 'I1' ]);

The I<one insertion> is easiest achieved with first disabling any
approximateness (C<0>) and then enabling one insertion (C<I1>).

=item Match 'perl' with zero deletions

	print if amatch('perl', [ 'D0' ]);

The I<zero deletion> is easily achieved with simply disabling any
deletions (C<D0>), the other types of differences, the insertions and
substitutions, are still enabled.

=item Substitute 'perl' approximately with HTML emboldening

	print if amatch('perl', '<B>$&</B>', [ 'g' ]);

All (C<g>) of the approximately matching parts of the input are
surrounded by the C<HTML> emboldening markup.

=back

=head2 Matching from a list

The above examples match against the default variable B<$_>.
The rest of the examples show how the match from a list.
The template is now:

	use String::Approx qw(amatch asubstitute);

	open(WORDS, "/usr/dict/words") or die;
	@words = <words>;
	# <---

and the examples still go where the 'C<# E<lt>--->' line is.

=item Match 'perl' with one difference from a list

	@matched = amatch('perl', @words);

The C<@matched> contains the elements of the C<@words> that matched
approximately.

=item Substitute 'perl' approximately with HTML emphasizing from a list

	@substituted = asubstitute('perl', '<EM>$&</EM>', [ 'g' ], @words);

The C<@substituted> contains B<with all> (C<g>) B<the substitutions>
the elements of the C<@words> that matched approximately.

=back

=head1 VERSION

Version 2.0.

=head1 LIMITATIONS

=head2 Fixed Pattern

The PATTERNs of C<amatch()> and C<asubstitute()> are fixed strings,
they are not regular expressions.  The I<SUBSTITUTION> of
C<asubstitute()> is a bit more flexible than that but not by much.

=head2 Speed

I<Despite the about 20-fold speed increase> from the C<String::Approx>
I<version 1> B<agrep is still faster>.  If you do not know what
C<agrep> is: it is a program like the UNIX grep but it knows, among
other things, how to do approximate matching.  C<agrep> is still about
30 times faster than I<Perl> + C<String::Approx>.  B<NOTE>: all these
speeds were measured in one particular system using one particular set
of tests: your mileage will vary.

=head2 Incompatibilities with C<String::Approx> I<v1.*>

If you have been using regular expression modifiers (B<i>, B<g>) you
lose.  Sorry about that.  The syntax simply is not compatible.  I had
to choose between having C<amatch()> match and C<asubstitute()>
substitute elsewhere than just in $_ I<and> the old messy way of
having an unlimited number of modifiers.  The first need won.

B<There is a backward compability mode>, though, if you do not want to
change your C<amatch()> and C<asubstitute()> calls.  You B<have> to
change your C<use> line, however:

	use String::Approx qw(amatch compat1);

That is, you must add the C<compat1> symbol if you want to be
compatible with the C<String::Approx> version 1 call syntax.

=head1 AUTHOR

Jarkko Hietaniemi C<E<lt>jhi@iki.fiE<gt>>

=head1 ACKNOWLEDGEMENTS

Nathan Torkington C<E<lt>gnat@frii.comE<gt>>

=cut

require 5;

use strict;
$^W = 1;

use vars qw($PACKAGE $VERSION $compat1
	    @ISA @EXPORT_OK
	    %M %S @aL @dL);

$PACKAGE = 'String::Approx';
$VERSION = '2.0';

$compat1 = 0;

require Exporter;

@ISA = qw(Exporter);

@EXPORT_OK = qw(amatch asubstitute);

# Catch the 'compat1' tag.

sub import {
    my $this = shift;
    my (@list, $sym);
    for $sym (@_) { $sym eq 'compat1' ? $compat1 = 1 : push(@list, $sym) }
    local $Exporter::ExportLevel = 1; 
    Exporter::import($this, @list);
}

sub _compile {
    my ($pattern, $I, $D, $S) = @_;

    my ($i, $d, $s) = ($I, $D, $S);
    my ($j, $p, %p, %q, $l, $k);

    $p{$pattern} = '';

    while ($i or $d or $s) {

	for $p (keys %p) { $p{$p} = length($p) }

	%q = ();
	
	# the insertions

	if ($i) {
	    $i--;
	    for $p (keys %p) {
		$l = $p{$p};
		for ($j = 1; $j < $l; $j++) {
		    $k = $p;
		    substr($k, $j) = '.' . substr($k, $j);
		    $q{$k} = '';
		}
	    }
	}

	# the deletions

	if ($d) {
	    $d--;
	    for $p (keys %p) {
		$l = $p{$p};
		for ($j = 0; $j < $l; $j++) {
		    $k = $p;
		    substr($k, $j) = substr($k, $j + 1);
		    $q{$k} = '';
		}
	    }
	}

	# the substitutions

	if ($s) {
	    $s--;
	    for $p (keys %p) {
		$l = $p{$p};
		for ($j = 0; $j < $l; $j++) {
		    $k = $p;
		    substr($k, $j, 1) = '.';
		    $q{$k} = '';
		}
	    }
	}

	@p{keys %q} = ''; # never mind the values
    }

    # the substitution pattern

    $S{$pattern}[$I][$D][$S] =
	join('|',
	     sort {
		 my $cmp;
		 # longer
		 return $cmp if $cmp = (length($b)      <=> length($a));
		 # more exact
		 return $cmp if $cmp = (($a =~ tr/././) <=> ($b =~ tr/././));
		 # never mind
	     } keys %p);

    # for amatch() drop the ones with leading or trailing '.'
    # they do not give any more matches.  for asubstitute() this
    # cannot be done because we want the longest possible matches.

    my (%m, $m);

    for $m (keys %p) { $m{$m} = '' unless $m =~ /^\./ or $m =~ /\.$/ }

    $M{$pattern}[$I][$D][$S] =
	join('|',
	     sort {
		 my $cmp;
		 # longer
		 return $cmp if $cmp = (length($b)      <=> length($a));
		 # more approximate
		 return $cmp if $cmp = (($b =~ tr/././) <=> ($a =~ tr/././));
		 # never mind
	     } keys %m);
}

sub _mods {
    my ($mods, $aI, $aD, $aS, $rI, $rD, $rS) = @_;
    my $remods = '';
    my $mod;

    for $mod (@$mods) {
	while ($mod ne '') {
	    if ($mod =~ s/^([IDS]?)(\d+)(%?)//) {
		if ($1 ne '') {
		    if ($3 ne '') {
			if    ($1 eq 'I') { $$rI = 0.01 * $2 }
			elsif ($1 eq 'D') { $$rD = 0.01 * $2 }
			else              { $$rS = 0.01 * $2 }
		    } else {
			if    ($1 eq 'I') { $$aI = $2 }
			elsif ($1 eq 'D') { $$aD = $2 }
			else              { $$aS = $2 }
		    }
		} else {
		    if ($3 ne '') {
			$$rI = $$rD = $$rS = 0.01 * $2;
		    } else {
			$$aI = $$aD = $$aS = $2;
		    }
		}
	    } elsif ($compat1 and $mod =~ s/^([igmsxo])//) {
		$remods .= $1;
	    } elsif ($mod =~ s/^([ig])//) {
		$remods .= $1;
	    } else {
		die $PACKAGE, ": unknown modifier '$mod'\n";
	    }
	}
    }

    $remods;
}

sub _mids {
    my ($len, $aI, $aD, $aS, $rI, $rD, $rS) = @_;

    my $r = int(0.1 * $len + 0.9);

    if    (    defined $rI) { $aI = int($rI * $len) }
    elsif (not defined $aI) { $aI = $r }

    if    (    defined $rD) { $aD = int($rD * $len) }
    elsif (not defined $aD) { $aD = $r }

    if    (    defined $rS) { $aS = int($rS * $len) }
    elsif (not defined $aS) { $aS = $r }

    ($aI, $aD, $aS);
}

sub amatch {
    my ($pattern, @list) = @_;
    my ($aI, $aD, $aS, $rI, $rD, $rS);

    my $len = length($pattern);

    my $remods;

    if ($compat1 or ref $list[0]) {
	my $mods;

	if ($compat1) {
	    $mods = [ @list ];
	    @list = ();
	} else {
	    $mods = shift(@list);
	}

	$remods = _mods($mods, \$aI, \$aD, \$aS, \$rI, \$rD, \$rS);

	($aI, $aD, $aS) = _mids($len, $aI, $aD, $aS, $rI, $rD, $rS);
    } else {
	$dL[$len] = int(0.1 * $len + 0.9) unless $dL[$len];
	$aI = $aD = $aS = $dL[$len];
    }

    _compile($pattern, $aI, $aD, $aS)
	unless defined $M{$pattern}[$aI][$aD][$aS];

    my $mpat = $M{$pattern}[$aI][$aD][$aS];

    $mpat = '(?' . $remods . ')' . $mpat if defined $remods;

    return grep /$mpat/, @list if @list;

    return ($_) if /$mpat/;

    ();
}

sub _subst {
    my ($sub, $pre, $match, $post) = @_;

    $sub =~ s/\$`/$pre/g;
    $sub =~ s/\$&/$match/g;
    $sub =~ s/\$'/$post/g;

    $sub;
}

sub asubstitute {
    my ($pattern, $sub, @list) = @_;
    my ($aI, $aD, $aS, $rI, $rD, $rS);

    my $len = length($pattern);

    my $remods;

    if ($compat1 or ref $list[0]) {
	my $mods;

	if ($compat1) {
	    $mods = [ @list ];
	    @list = ();
	} else {
	    $mods = shift(@list);
	}

	$remods = _mods($mods, \$aI, \$aD, \$aS, \$rI, \$rD, \$rS);

	($aI, $aD, $aS) = _mids($len, $aI, $aD, $aS, $rI, $rD, $rS);
    } else {
	$dL[$len] = $len < 11 ? 1 : int(0.1 * $len) unless $dL[$len];
	$aI = $aD = $aS = $dL[$len];
    }

    _compile($pattern, $aI, $aD, $aS)
	unless defined $S{$pattern}[$aI][$aD][$aS];

    my $spat = $S{$pattern}[$aI][$aD][$aS];
    
    $spat = '(?' . $remods . ')' . $spat if defined $remods;

    if (@list) {
	my (@m, $s);

	for $s (@list) {
	    push(@m, $s) if $s =~ s/($spat)/_subst($sub, $`, $1, $')/e
	}

	return @m;
    }

    return ($_) if s/($spat)/_subst($sub, $`, $1, $')/e;

    ();
}

1;

# eof
