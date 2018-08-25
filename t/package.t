#!perl
use warnings FATAL => 'all';
use strict;

package Bar;
BEGIN {
package Bar; our %PECK = ('peek' => 1);
    package Foo;

    use Keyword::Pluggable;

    Keyword::Pluggable::define peek => sub {
        substr ${$_[0]}, 0, 0, "ok 1, 'synthetic test 1';";
    }, 0, 1, 'Bar';
    Keyword::Pluggable::define poke => sub {
        substr ${$_[0]}, 0, 0, "ok 2, 'synthetic test 2';";
    }, 1, 1, 'Bar';
}

package Bar;
use Test::More tests => 5;

peek
ok 1, "natural test 1";
poke
ok 2, "natural test 2";

package Meke;
eval "peek;";
Test::More::ok(defined($@), 'failed outside package ok');
