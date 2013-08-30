#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'WWW::FC2' ) || print "Bail out!\n";
}

diag( "Testing WWW::FC2 $WWW::FC2::VERSION, Perl $], $^X" );
