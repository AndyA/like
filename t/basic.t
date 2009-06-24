#!perl

package Foo;

use latest;
use like qw( if::this );

package if::that;

BEGIN { our @ISA = qw( if::this ) }

package Bar;

use latest;
use like qw( if::this if::that );

package main;

use latest;
use like;

use Test::More tests => 9;

isa_ok 'Foo', 'if::this';
isa_ok 'Bar', 'if::that';
isa_ok 'Bar', 'if::this';

# make sure we didn't clobber if::that's @ISA
isa_ok 'if::that', 'if::this';

ok !Foo->isa( 'if::that' ),      "Foo ain't all that";
ok !Bar->isa( 'if::imaginary' ), "Bar ain't deluded";

is_deeply [ things_like 'if::this' ], [ 'Bar', 'Foo', 'if::that' ],
 'Like this';
is_deeply [ things_like 'if::that' ], ['Bar'], 'Like that';
is_deeply [ things_like 'if::other' ], [], 'Like nothing on earth';

# vim:ts=2:sw=2:et:ft=perl

