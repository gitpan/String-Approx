use String::Approx 'aregex';

chdir('t') or die "could not chdir to 't'";

require 't'; # har har

# String::Approx::debug(1);

print "1..2\n";

# test 1

{
my (@regex) = aregex('Obi-wan Kenobi');
print "not "
    unless @regex == 2
           and $regex[0] eq
'(?:.bi-wan|O(?:.(?=[bi])(?:bi-wan|i-wan)|b(?:-wan|.(?=[-i])(?:-wan|i-wan)|i(?:-(?:.(?:w?an)|an|w(?:.(?:a?n)|a(?:.n?|n)?|n))|.(?:-?wan)|wan))|i-wan)|bi-wan)'
	   and $regex[1] eq
'(?: (?:.(?:K?enobi)|K(?:.(?:e?nobi)|e(?:.(?:n?obi)|n(?:.(?:o?bi)|bi|o(?:.(?:b?i)|b(?:.i?|i)?|i))|obi)|nobi)|enobi)|.(?: ?Kenobi)|Kenobi)';

print "ok 1\n";
}

# test 2

{
my (@regex) = aregex('Obi-wan Kenobi', [q(std)]);
print "not "
    unless @regex == 2
           and $regex[0] eq
'(.bi-wan|O(.(bi-wan|i-wan)|b(-wan|.(-wan|i-wan)|i(-(.(w?an)|an|w(.(a?n)|a(.n?|n)?|n))|.(-?wan)|wan))|i-wan)|bi-wan)'
          and $regex[1] eq
'( (.(K?enobi)|K(.(e?nobi)|e(.(n?obi)|n(.(o?bi)|bi|o(.(b?i)|b(.i?|i)?|i))|obi)|nobi)|enobi)|.( ?Kenobi)|Kenobi)';

print "ok 2\n";
}

# eof
