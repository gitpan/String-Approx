use String::Approx 'aindex';

chdir('t') or die "could not chdir to 't'";

print "1..12\n";

print "not " unless aindex("xyz", "abcdef")    == -1;
print "ok 1\n";

print "not " unless aindex("xyz", "abcdefxyz") ==  6;
print "ok 2\n";

print "not " unless aindex("xyz", "abcdefxgh") == -1;
print "ok 3\n";

print "not " unless aindex("xyz", "abcdefyzg") ==  6;
print "ok 4\n";

print "not " unless aindex("xyz", "abcdefxgz") ==  6;
print "ok 5\n";

print "not " unless aindex("xyz", "abcdexfyz") ==  5;
print "ok 6\n";

print "not " unless aindex("xyz", ["initial_position=3"], "xyzabcde") == -1;
print "ok 7\n";

print "not " unless aindex("xyz", ["initial_position=1"], "xyzabcde") ==  1;
print "ok 8\n";

print "not " unless aindex("xyz", ["final_position=5"],   "abcdexyz") == -1;
print "ok 9\n";

print "not " unless aindex("xyz", ["initial_position=2",
	                           "final_position=6"],   "xyzabcxyz") == -1;
print "ok 10\n";

print "not " unless aindex("xyz", ["initial_position=2",
	                           "final_position=7"],   "xyzabcxyz") ==  6;
print "ok 11\n";

print "not " unless aindex("xyz", ["initial_position=1",
	                           "final_position=6"],   "xyzabcxyz") ==  1;
print "ok 12\n";

# that's it.
