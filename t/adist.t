use String::Approx qw(adist adistr adistword adistrword);

chdir('t') or die "could not chdir to 't'";

print "1..26\n";

print "not " unless adist("abc", "abc") == 0;
print "ok 1\n";

print "not " unless adist("abc", "abd") == 1;
print "ok 2\n";

print "not " unless adist("abc", "ade") == 2;
print "ok 3\n";

print "not " unless adist("abc", "def") == 3;
print "ok 4\n";

print "not " unless adistr("abc", "abd") == 1/3;
print "ok 5\n";

$a = adist("abc", ["abc", "abd", "ade", "def"]);

print "not " unless $a->[0] == 0;
print "ok 6\n";

print "not " unless $a->[1] == 1;
print "ok 7\n";

print "not " unless $a->[2] == 2;
print "ok 8\n";

print "not " unless $a->[3] == 3;
print "ok 9\n";

print "not " unless @$a == 4;
print "ok 10\n";

$a = adist(["abc", "abd", "ade", "def"], "abc");

print "not " unless $a->[0] == 0;
print "ok 11\n";

print "not " unless $a->[1] == 1;
print "ok 12\n";

print "not " unless $a->[2] == 2;
print "ok 13\n";

print "not " unless $a->[3] == 3;
print "ok 14\n";

print "not " unless @$a == 4;
print "ok 15\n";

$a = adist(["abc", "abd", "ade", "def"], ["abc", "abd", "ade", "def"]);

print "not " unless $a->[0]->[0] == 0;
print "ok 16\n";

print "not " unless $a->[1]->[2] == 2;
print "ok 17\n";

print "not " unless $a->[2]->[1] == 1;
print "ok 18\n";

print "not " unless $a->[3]->[3] == 0;
print "ok 19\n";

print "not " unless @$a == 4;
print "ok 20\n";

print "not " unless adist("abcd", "abc") == -1;
print "ok 21\n";

print "not " unless adistr("abcd", "abc") == -1/4;
print "ok 22\n";

print "not " unless adist("abcde", "abc") == -2;
print "ok 23\n";

print "not " unless adistr("abcde", "abc") == -2/5;
print "ok 24\n";

my @a = adist("abc", "abd", "ade", "def");

print "not " unless $a[2] == 3;
print "ok 25\n";

{
    my @abd = ("abd", "bad");
    my @r = adistr("abc", @abd);
    print "not " unless @r == 2 && $r[0] == 1/3 && $r[1] == 2/3;
    print "ok 26\n";
}


