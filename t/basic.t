#!perl
use warnings FATAL => 'all';
use strict;

use Test::More tests => 4;

{
    package Foo;

    use Keyword::Pluggable;

    sub import {
        Keyword::Pluggable::define peek => sub {
            substr ${$_[0]}, 0, 0, "ok 1, 'synthetic test 1';";
        };
        Keyword::Pluggable::define poke => sub {
            substr ${$_[0]}, 0, 0, "ok 2, 'synthetic test 2';";
        }, 1;
    }

    sub unimport {
        Keyword::Pluggable::undefine 'peek';
        Keyword::Pluggable::undefine 'poke';
    }

    BEGIN { $INC{"Foo.pm"} = 1; }
}

use Foo;

peek
ok 1, "natural test 1";
poke
ok 2, "natural test 2";
