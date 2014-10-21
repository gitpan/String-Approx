package String::Approx;

$VERSION = 3.03;

use strict;
local $^W = 1;

use Carp;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

require Exporter;
require DynaLoader;

@ISA = qw(Exporter DynaLoader);

@EXPORT_OK = qw(amatch asubstitute);

bootstrap String::Approx $VERSION;

my %_simple;

sub _simple {
    my $P = shift;

    $_simple{$P} = new(__PACKAGE__, $P) unless exists $_simple{$P};

    return ( $_simple{$P} );
}

sub _parse_param {
    use integer;

    my ($n, @param) = @_;
    my %param;

    foreach (@param) {
        s/^\s+//;
        while ($_ ne '') {
            if (s/^([IDS])?(\d+)(%)?//) {
                my $k = defined $3 ? (($2-1) * $n) / 100 + 1 : $2;

		if (defined $1) {
		    $param{$1} = $k;
		} else {
		    $param{k}  = $k;
		}
            } elsif (s/^i//) {
                $param{ i } = 1;
            } elsif (s/^g//) {
                $param{ g } = 1;
            } elsif (s/^\?//) {
                $param{'?'} = 1;
            } else {
                die "unknown match parameter: $_\n";
            }
        }
    }

    return %param;
}

my %_param_key;
my %_parsed_param;

my %_complex;

sub _complex {
    my ($P, @param) = @_;
    my $param = "@param";
    my $_param_key;
    my %param;

    unless (exists $_param_key{$param}) {
	%param = _parse_param(length($P), @param);
	$_parsed_param{$param} = { %param };
	$_param_key{$param} = join(" ", %param);
    } else {
	%param = %{ $_parsed_param{$param} };
    }

    $_param_key = $_param_key{$param};

    unless (exists $_complex{$P}->{$_param_key}) {
	$_complex{$P}->{$_param_key} = new(__PACKAGE__, $P)
	    unless exists $_complex{$P}->{$_param_key};

	$_complex{$P}->{$_param_key}->set_greedy unless exists $param{'?'};

	if (exists $param{'k'}) {
	    $_complex{$P}->{$_param_key} = new(__PACKAGE__, $P, $param{k});
	} else {
	    $_complex{$P}->{$_param_key} = new(__PACKAGE__, $P);
	}

	$_complex{$P}->{$_param_key}->set_insertions($param{'I'})
	    if exists $param{'I'};
	$_complex{$P}->{$_param_key}->set_deletions($param{'D'})
	    if exists $param{'D'};
	$_complex{$P}->{$_param_key}->set_substitutions($param{'S'})
	    if exists $param{'S'};
	
	$_complex{$P}->{$_param_key}->set_caseignore_slice
	    if exists $param{'i'};
    }

    return ( $_complex{$P}->{$_param_key}, %param );
}

sub amatch {
    my $P = shift;
    my $a = ((@_ && ref $_[0] eq 'ARRAY') ?
		 _complex($P, @{ shift(@_) }) : _simple($P))[0];

    if (@_) {
        if (wantarray) {
            return grep { $a->match($_) } @_;
        } else {
            foreach (@_) {
                return 1 if $a->match($_);
            }
             return 0;
        }
    } 
    if (defined $_) {
        if (wantarray) {
            return $a->match($_) ? $_ : undef;
        } else {
	    return 1 if $a->match($_);
        }
    } 
    return        $a->match($_)      if defined $_;
    die "amatch: \$_ is undefined: what are you matching?\n";
}

sub _find_substitute {
    my ($ri, $rs, $i, $s, $S, $rn) = @_;

    push @{ $ri }, $i;
    push @{ $rs }, $s;

    my $pre = substr($_, 0, $i);
    my $old = substr($_, $i, $s);
    my $suf = substr($_, $i + $s);
    my $new = $S;

    $new =~ s/\$\`/$pre/g;
    $new =~ s/\$\&/$old/g;
    $new =~ s/\$\'/$suf/g;

    push @{ $rn }, $new;
}

sub _do_substitute {
    my ($rn, $ri, $rs, $rS) = @_;

    my $d = 0;
    my $n = $_;

    foreach my $i (0..$#$rn) {
	substr($n, $ri->[$i] + $d, $rs->[$i]) = $rn->[$i];
	$d += length($rn->[$i]) - $rs->[$i];
    }

    push @{ $rS }, $n;
}

sub asubstitute {
    my $P = shift;
    my $S = shift;
    my ($a, %p) =
	(@_ && ref $_[0] eq 'ARRAY') ?
	    _complex($P, @{ shift(@_) }) : _simple($P);

    my ($i, $s, @i, @s, @n, @S);

    if (@_) {
	if (exists $p{ g }) {
	    foreach (@_) {
		@s = @i = @n = ();
		while (($i, $s) = $a->slice_next($_)) {
		    if (defined $i) {
			_find_substitute(\@i, \@s, $i, $s, $S, \@n);
		    }
		}
		_do_substitute(\@n, \@i, \@s, \@S) if @n;
	    }
	} else {
	    foreach (@_) {
		@s = @i = @n = ();
		($i, $s) = $a->slice($_);
		if (defined $i) {
		    _find_substitute(\@i, \@s, $i, $s, $S, \@n);
		    _do_substitute(\@n, \@i, \@s, \@S);
		}
	    }
	}
	return @S;
    } elsif (defined $_) {
	if (exists $p{ g }) {
	    while (($i, $s) = $a->slice_next($_)) {
		if (defined $i) {
		    _find_substitute(\@i, \@s, $i, $s, $S, \@n);
		}
	    }
	    _do_substitute(\@n, \@i, \@s, \@S) if @n;
	} else {
	    ($i, $s) = $a->slice($_);
	    if (defined $i) {
		_find_substitute(\@i, \@s, $i, $s, $S, \@n);
		_do_substitute(\@n, \@i, \@s, \@S);
	    }
	}
	return $n[0];
    } else {
	die "asubstitute: \$_ is undefined: what are you substituting?\n";
    }
}

1;
__END__

=head1 NAME

String::Approx - Perl extension for approximate matching (fuzzy matching)

=head1 SYNOPSIS

  use String::Approx 'amatch';

  print if amatch("foobar");

  @matches = amatch("xyzzy", @inputs);

  @matches = amatch("plugh", ['2'], @inputs);

=head1 DESCRIPTION

String::Approx lets you match and substitute strings approximately.
With approximateness you can emulate errors: typing errorrs, speling
errors, closely related vocabularies (colour color), genetic mutations
(GAG ACT), abbreviations (McScot, MacScot).

The measure of B<approximateness> is the I<Levenshtein edit distance>.
It is the total number of "edits": insertions,

	word world

deletions,

	monkey money

and substitutions

	sun fun

required to transform a string to another string.  For example, to
transform "lead" to "gold", you need three edits:

	lead gead goad gold

The edit distance of "lead" and "gold" is therefore three.

=head1 MATCH

	use String::Approx 'amatch';

	amatch("pattern") 
	amatch("pattern", @inputs) 
	amatch("pattern", [ modifiers ])
	amatch("pattern", [ modifiers ], @inputs)

Match B<pattern> approximately.  In list context return the matched
B<@inputs>.  If no inputs are given, match against the B<$_>.  In scalar
context return true if I<any> of the inputs match, false if none match.

Notice that the pattern is a string.  Not a regular expression.
None of the regular expression notations (^, ., *, and so on) work.
They are characters just like the others.

=head2 MODIFIERS

With the modifiers you can control the amount of approximateness
and certain other variables.  The modifiers are one or more strings,
for example "i".  The modifiers are inside an anonymous array: the [ ]
in the syntax are not notational, they really do mean [ ],
for example [ "i", "2" ].  ["2 i"] would be identical.

The implicit default approximateness is 10%, rounded up.  In other
words: every tenth character in the pattern may be an error, an edit.
You can explicitly set the maximum approximateness by supplying a
modifier like

	number
	number%

Examples: "3", "15%".

Using a similar syntax you can separately control the maximum number
of insertions, deletions, and substitutions by prefixing the numbers
with I, D, or S, like this:

	Inumber
	Inumber%
	Dnumber
	Dnumber%
	Snumber
	Snumber%

Examples: "I2", "D20%", "S0".

You can ignore case ("A" becames equal to "a" and vice versa)
by adding the "i" modifier.

For example

	[ "i 25%", "S0" ]

means I<ignore case>, I<allow every fourth character to be "an edit">,
but allow I<no substitutions>.  (See L<NOTES> about disallowing
substitutions or insertions.)

=head1 SUBSTITUTE

	use String::Approx 'asubstitute';

	asubstitute("pattern", "replacement")
	asubstitute("pattern", "replacement", @inputs) 
	asubstitute("pattern", "replacement", [ modifiers ])
	asubstitute("pattern", "replacement", [ modifiers ], @inputs)

Substitute approximate B<pattern> with B<replacement> and return
I<copies> of B<@inputs>, the substitutions having been made on the
elements that did match the pattern.  If no inputs are given,
substitute in the B<$_>.  The replacement can contain magic strings
B<$&>, B<$`>, B<$'> that stand for the matched string, the string
before it, and the string after it, respectively.  All the other
arguments are as in C<amatch()>, plus one additional modifier, C<"g">
which means substitute globally (all the matches in an elemnt and not
just the first one, as is the default).

See L<BAD NEWS> about the unfortunate stinginess of C<asubstitute()>.

=head1 NOTES

Because matching is by I<substrings>, not by whole strings, insertions
and substitutions produce often very similar results: "abcde" matches
"axbcde" either by insertion B<or> substitution of "x".

The maximum edit distance is also the maximum number of edits.
That is, the C<"I2"> in

	amatch("abcd", ["I2"])

is useless because the maximum edit distance is (implicitly) 1.
You may have meant to say

	amatch("abcd", ["2D1S1"])

or something like that.

If you want to simulate transposes

	feet fete

you need to allow at least edit distance of two because in terms of
our edit primitives a transpose is one deletion and one insertion.

=head1 VERSION

3.0.

=head1 CHANGES FROM VERSION 2

=head2 GOOD NEWS

=over 4

=item The version 3 is 2-3 times faster than version 2

=item No pattern length limitation

The algorithm is independent on the pattern length: its time
complexity is I<O(kn)>, where I<k> is the number of edits and I<n> the
length of the text (input).

=back

=head2 BAD NEWS

=over 4

=item You do need a C compiler to install the module

Perl's regular expressions are no more used; instead a faster and more
scalable algorithm written in C is used.

=item C<asubstitute()> is now always stingy

The string matched and substituted is now always stingy, as short
as possible.  It used to be as long as possible.  This is an unfortunate
change stemming from switching the matching algorithm.  Example: with
edit distance of two and substituting for C<"word"> from C<"cork"> and
C<"wool"> previously did match C<"cork"> and C<"wool">.  Now it does
match C<"or"> and C<"wo">.  As little as possible, or, in other words,
with as much approximateness, as many edits, as possible.  Because
there is no I<need> to match the C<"c"> of C<"cork">, it is not matched.

=item no more C<aregex()> because regular expressions are no more used

=item no more C<compat1> for String::Approx version 1 compatibility

=back

=head1 ACKNOWLEDGEMENTS

The following people provided with valuable test cases and other feedback:
Jared August, Steve A. Chervitz, Alberto Fontaneda, Dmitrij Frishman,
Lars Gregersen, Kevin Greiner, Ricky Houghton, Helmut Jarausch,
Sergey Novoselov, Stewart Russell, Slaven Rezic, Ilya Sandler,
Bob J.A. Schijvenaars, Greg Ward, Rick Wise.

The matching algorithm was developed by Udi Manber, Sun Wu, and Burra
Gopal in the Department of Computer Science, University of Arizona.

=head1 AUTHOR

Jarkko Hietaniemi <jhi@iki.fi>

=cut
