package String::Approx;

require 5;

require Exporter;

use Carp;

@ISA = qw(Exporter);
@EXPORT_OK = qw(amatch asubstitute);

my $debug = 0;

=head1 NAME

String::Approx - approximate matching and substitution

=head1 SYNOPSIS

	use String::Approx qw(amatch asubstitute);

	# amatch() and asubstitute imported to the current namespace,
	# by default _nothing_ is imported

=head1 DESCRIPTION

C<String::Approx> is a Perl module for matching and substituting
strings in a fuzzy way - approximately.

=head2 amatch

	amatch($approximate_string[, ...]);

All the other amatch() arguments are optional except the
$approximate_string itself.

The additional parameters are strings of any the forms:

	number		e.g. '1', the maximum number of transformations
			for all the transformation types,
			the types being insert/delete/substitute

	number%		e.g. '15%', the relative maximum number of
			all the transformations is 15% of the
			approximating string

	[IDS]number	e.g. 'I2', the maximum number of insertions

	[IDS]number%	e.g. 'D20%', the relative maximum number of
			deletions is 20% of the length of the
			approximating string

	[gimosx]	e.g. 'im', the usual m// modifiers

The default is parameter '10%'. Two noteworthy points:

	the relative amounts, especially the default 10%,
	would often result in number of allowed 'errors' being
	less than 1. this, however, does not happen. internally
	the minimum is forced to be 1.
	(0 can be and must be explicitly asked for)

	the relative amounts are rounded to the nearest whole
	number in the standard way, e.g. 10% of 15 will end up
	being 2.

You can combine all the number parameter types into a single string,
e.g. '15%i2'.

An example:

	use String::Approx qw(amatch);

	open(WORDS, '/usr/dict/words') or die;

	while (<WORDS>) {
	  print if amatch('perl');
	}

=head2 asubstitute

	asubstitute($approximate_string, $substitute[, ...]);

Otherwise identical parameters with amatch() except that the
second argument is the substitution string, $substitute.

One can use in the substitution string the special marker C<$&> that
represents the approximately matched string.

An example:

	use String::Approx qw(asubstitute);

	open(WORDS, '/usr/dict/words') or die;

	while (<WORDS>) {
	  print if asubstitute('perl', '<$&>);
	}

=head1 RETURN VALUES

In scalar context amatch() and asubstitute() return the number of
possible matches and substitutions. In list context they return the
list all the possible matches and substitutions. Note that in the case
of asubstitute() the list of possible substitutions may be longer than
the list of done substitutions because possible substitutions may overlap.
The first and the longest substitutions are done first, the rest are done
if they do not overlap the already one substitutions.

As a side-effect asubstitute() may change the value of $_ if approximate
matches are found.

Note that error messages and warnings come from amatch(), not from
asubstitute().

=head2 More Examples

	amatch($s);		# the maximum amount of approximateness
				# is max(1,10_%_of_length($s))
	amatch($s, 1);		# the maximum number of any
				# insertions/deletes/substitutions
				# (_separately_) is 1
	amatch($s, 'I1D0S30%');	# the maximum amount for insertions is 1,
	       			# deletions are not allowed, the maximum
				# amount of substitutions
				# is max(1,5_%_of_length($s))

	asubstitute($s, '($&)', 'g');
				# surround in $_ all ('g') the approximate
				# matches by parentheses

	asubstitute($s, '&func', 'e');
				# substitute in $_ the first approximate
				# match with the result of &func (without
				# the 'e' literal string '&func' would be
				# the substitute)


=head1 LIMITATIONS

B<You cannot mix approximate matching and normal Perl regular
expressions (see perlre).  Please do not even think about it>.

Do B<not> use characters C<.?*+{}[](|)^$\> (that is, any characters
that have special meaning in regular expressions) in your approximate
strings.

Matching and substitution are always done on $_. The =~ binding
operator (see perlop) can only be used with the Perl builtins m//,
s///, and tr///, not for user-defined functions such as amatch().

The C<agrep> B<is> faster. Searching for C<'perl'> with one each [IDS]
allowed from a wordlist of 25486 words took with C<amatch()> 656
seconds on a RISC box while C<agrep> took 0.77 seconds. This is mainly
because C<String::Approx> does the same things with an interpreted
language, Perl, whereas agrep does it in compiled, language, C, and
because doing approximate matching is very demanding operation,
especially the substitutions.  C<String::Approx> does it by (ab)using
regular expressions which is quite wasteful, approximate matching
should be built in Perl for it to be fast.  The time taken by the
insertion operation, I<I>, is about 30%, by the deletion, I<D>, about
20%, and by the substitution, I<S>, about 50%.  (In case you are
wondering, yes, agrep and amatch() did agree on the list of matching
words)

=head1 VERSION

v1.6

=head1 AUTHOR

Jarkko Hietaniemi, C<jhi@iki.fi>

=cut

%R = (); # cache for the approximate matching regexps
@L = (); # cache for the length expressions

$R = 20;

sub flushR {
  %R = ();
}

sub R {
  if (@_ == 2) {
    $R{$_[0]}->{$_[1]};
  } else {
    flushR() if (scalar keys %R > $R);
    $R{$_[0]}->{$_[1]} = $_[2];
  }
}

sub L {
  @_ == 1 ? $L[$_[0]] : ($L[$_[0]]  = $_[1]);
}

use strict qw(subs vars);

sub _pct {
  my ($s, $p) = @_;
  my $fuzz = int($p * length($s) + .5);

  $fuzz > 1 ? $fuzz : 1;
}

sub _argh {
  my ($str) = shift;

  croak "amatch: approximate string undefined" unless defined $str;

  my ($prm, $mod, $g, $e, $ins, $del, $sbs);

  $g = 0;
  $e = 0;
  undef $ins;
  undef $del;
  undef $sbs;
  $mod = '';

  while (($prm = shift) ne '') {
    if ($prm =~ /^[egimosx]+$/) {
      $g += $prm =~ tr/g//d;
      $e += $prm =~ tr/e//d;
      $mod = $prm;
    } else {
      while ($prm =~ s/^(?:([idr])\s*)?(\d+)(?:\s*(%))?//) {
	my $r;
      
	if ($3 eq '%') {
	  $r = _pct($str, $2/100);
	} else {
	  $r = $2;
	}

	if ($1 eq 'I') {
	  $ins = $r;
	} elsif ($1 eq 'D') {
	  $del = $r;
	} elsif ($1 eq 'S') {
	  $sbs = $r;
	} elsif ($1 eq '') {
	  $ins = $del = $sbs = $r;
	}
      }
    }
    croak "unknown parameter '$prm'" if ($prm ne '');
  }
  
  $ins = _pct($str, .1) unless (defined $ins);
  $del = _pct($str, .1) unless (defined $del);
  $sbs = _pct($str, .1) unless (defined $sbs);
  $mod = "($mod)" if ($mod ne '');

  ($str, $mod, $g, $e, $ins, $del, $sbs);
}

sub _match {
  my ($str, $mod, $g, $e, $ins, $del, $sbs) = _argh(@_);
  my @m = ();

  if (/$mod$str/g) {
    push(@m, [$&, pos()]);
    return ($e, @m) unless ($g);
  }

  my @str  = split(//, $str);
  my $size = length($str);
  
  carp "amatch: insertions ($ins) >= size of approximate string ($size)"
    if ($ins >= $size);

  carp "amatch: deletions ($del) >= size of approximate string ($size)"
    if ($del >= $size);

  carp "amatch: substitutions ($sbs) >= size of approximate string ($size)"
    if ($sbs >= $size);

  R($str, "I$ins", join("(.{0,$size}?)", @str))
    if ($ins and not defined R($str, "I$ins"));
  
  R($str, "D$del", '('.join('', map { "$_?" } @str).')')
    if ($del and not defined R($str, "D$del"));

  R($str, "S$sbs", join('', map { "(?:($_)|.)" } @str))
    if ($sbs and not defined R($str, "S$sbs"));

  L($#str, 'length("'.join('', map { "\$$_" } 1..$size).'")')
    unless (defined L($#str));

  my $save = $_;
  my ($pat, $len);
  
  if (0 and $ins) {
    for($pat = R($str, "I$ins"), $_ = $save; /$mod$pat/g;) {
      if ($len = eval L($#str) and $len <= $ins) {
	push(@m, [$&, pos()]);
	return ($e, @m) unless ($g);
      }
    }
  }

  if ($del) {
    for ($pat = R($str, "D$del"), $_ = $save; /$mod$pat/g;) {
      if (length($1) > $#str - $del) {
	push(@m, [$&, pos()]);
	return ($e, @m) unless ($g);
      }
    }
  }

  if ($sbs) {
    my $limsbs = $#str - $sbs;

    for ($pat = R($str, "S$sbs"), $_ = $save; /$mod$pat/g;) {
      if (($len = eval L($#str)) > $limsbs) {
	push(@m, [$&, pos()]);
	return ($e, @m) unless ($g);
      }
      pos() = pos() - $size; # backtrack
      pos() = pos() + (/^([^$str]+)/g ? length($1) : 1); # forward skip
    }
  }

  if (@m) {
    # start positions more interesting than end positions
    for (@m) { $$_[1] = $$_[1] - length($$_[0]) }
    if (@m > 1) { # need a sort?
      my $cmp;

      no strict; # $a and $b of sort() confuse strict var
      @m = sort {
	$cmp = $$a[1] <=> $$b[1]; # primary key: start positions
	return $cmp if ($cmp);
	length($$b[0]) <=> length($$a[0]) # secondary key: longer first
	} @m;
      use strict;
    }
  }

  ($e, @m);
}

sub amatch {
  my ($e, @m) =  _match(@_);

  wantarray() ? map { $$_[0] } @m : @m;
}

sub asubstitute {
  my $s = splice(@_, 1, 1);
  my ($e, @m) = _match(@_);
  my ($i, $ne, $es, $vi, $od, @s);

  $od = 0;
  @s = @m;
  while ($i = shift(@s)) {
    $es = $s;
    $es =~ s/\$&/$$i[0]/eg;
    for ($ne = $e; $ne; $ne--) {
      $es = eval $es;
      $es =~ s/\$&/$$i[0]/eg;
    }
    substr($_, $$i[1] - length($s) + 1 + $od, length($$i[0])) = $es;
    $vi = $$i[1] + length($$i[0]) + $od;
    while (@s and $s[0][1] + $od < $vi) { shift(@s) }
    $od += length($es) - length($$i[0]);
  }
  
  wantarray() ? map { $$_[0] } @m : scalar @m;
}

1; # keep require happy

# eof
