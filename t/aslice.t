use String::Approx 'aslice';

chdir('t') or die "could not chdir to 't'";

require 'util';

print "1..6\n";

@s = aslice("xyz", "abcdef");
print "not " unless @s == 1 && @{$s[0]} == 0;
print "ok 1\n";

@s = aslice("xyz", "abcdefxyzghi");
print "not " unless @s == 1 && $s[0]->[0] == 6 && $s[0]->[1] == 4;
print "ok 2\n";

@s = aslice("xyz", ["i"], "ABCDEFXYZGHI");
print "not " unless @s == 1 && $s[0]->[0] == 6 && $s[0]->[1] == 4;
print "ok 3\n";

@s = aslice("xyz", ["minimal_distance"], "abcdefx!yzghi");
print "# @{$s[0]}\n";
print "not "
	unless @s == 1 && $s[0]->[0] == 6 &&
	       $s[0]->[1] == 4 && $s[0]->[2] == 1;
print "ok 4\n";

@s = aslice("xyz", ["minimal_distance"], "abcdefxzghi");
print "# @{$s[0]}\n";
print "not "
	unless @s == 1 && $s[0]->[0] == 6 &&
	       $s[0]->[1] == 2 && $s[0]->[2] == 1;
print "ok 5\n";

@s = aslice("xyz", ["minimal_distance"], "abcdefx!zghi");
print "# @{$s[0]}\n";
print "not "
	unless @s == 1 && $s[0]->[0] == 6 &&
	       $s[0]->[1] == 3 && $s[0]->[2] == 1;
print "ok 6\n";

# that's it.
