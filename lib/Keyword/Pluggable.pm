package Keyword::Pluggable;

use v5.14.0;
use warnings;
our %kw;

use Carp qw(croak);

use XSLoader;
BEGIN {
	our $VERSION = '1.00';
	XSLoader::load __PACKAGE__, $VERSION;
}

sub define {
	my ($kw, $sub, $expression, $global, $package) = @_;
	$kw =~ /^\p{XIDS}\p{XIDC}*\z/ or croak "'$kw' doesn't look like an identifier";
	ref($sub) eq 'CODE' or croak "'$sub' doesn't look like a coderef";

	my $entry = [ $sub, !!$expression ];
	if ( defined $package) {
		no strict 'refs';
		my $keywords = \%{$package . '::/keywords' };
		$keywords->{$kw} = $entry;
	} elsif ( $global ) {
		define_global($kw, $entry);
	} else {
		my %keywords = %{$^H{+HINTK_KEYWORDS} // {}};
		$keywords{$kw} = $entry;
		$^H{+HINTK_KEYWORDS} = \%keywords;
	}
}

sub undefine {
	my ($kw, $global, $package) = @_;
	$kw =~ /^\p{XIDS}\p{XIDC}*\z/ or croak "'$kw' doesn't look like an identifier";

	if ( defined $package ) {
		no strict 'refs';
		my $keywords = \%{$package . '::/keywords' };
		delete $keywords->{$kw};
	} elsif ( $global ) {
		undefine_global($kw);
	} else {
		my %keywords = %{$^H{+HINTK_KEYWORDS} // {}};
		delete $keywords{$kw};
		$^H{+HINTK_KEYWORDS} = \%keywords;
	}
}

END { cleanup() }

'ok'

__END__

=encoding UTF-8

=for highlighter language=perl

=head1 NAME

Keyword::Pluggable - define new keywords in pure Perl

=head1 SYNOPSIS

 package Some::Module;
 
 use Keyword::Pluggable;
 
 sub import {
	 # create keyword 'provided', expand it to 'if' at parse time
	 Keyword::Pluggable::define 'provided', sub {
		 my ($ref) = @_;
		 substr($$ref, 0, 0) = 'if';  # inject 'if' at beginning of parse buffer
	 };
 }
 
 sub unimport {
	 # lexically disable keyword again
	 Keyword::Pluggable::undefine 'provided';
 }

 'ok'

=head1 DESCRIPTION

Warning: This module is still new and experimental. The API may change in
future versions. The code may be buggy. Also, this module is a fork from
C<Keyword::Simple>, that somehow got stalled. If its author accepts pull requests,
then it will probably be best to use it instead.

This module lets you implement new keywords in pure Perl. To do this, you need
to write a module and call
L<C<Keyword::Pluggable::define>|/Keyword::Pluggable::define> in your C<import>
method. Any keywords defined this way will be available in the lexical scope
that's currently being compiled.

=head2 Functions

=over

=item C<Keyword::Pluggable::define> $keyword, $coderef, $is_expression, $is_global

Takes four arguments, the name of a keyword, a coderef, a boolean flag if the
result of the keyword handler is an expression, and global flag. Injects the
keyword in either the lexical or global scope currently being compiled. For
every occurrence of the keyword, your coderef will be called with one argument:
A reference to a scalar holding the rest of the source code (following the
keyword).

You can modify this scalar in any way you like and after your coderef returns,
perl will continue parsing from that scalar as if its contents had been the
real source code in the first place.

=item C<Keyword::Pluggable::undefine> $keyword, $is_global

Takes two argument, the name of a keyword, and the global flag. Disables that
keyword either in the lexical or global scope that's currently being compiled. You can call this
from your C<unimport> method to make the C<no Foo;> syntax work.

=back

=head1 BUGS AND LIMITATIONS

This module depends on the L<pluggable keyword|perlapi.html/PL_keyword_plugin>
API introduced in perl 5.12. C<parse_> functions were introduced in 5.14.
Older versions of perl are not supported.

Every new keyword is actually a complete statement or an expression by itself. The parsing magic
only happens afterwards. This means that e.g. the code in the L</SYNOPSIS>
actually does this:

  provided ($foo > 2) {
	...
  }

  # expands to

  ; if
  ($foo > 2) {
	...
  }

The C<;> represents a no-op statement, the C<if> was injected by the Perl code,
and the rest of the file is unchanged.

This also means your new keywords can only occur at the beginning of a
statement, not embedded in an expression.

Keywords in the replacement part of a C<s//.../e> substitution aren't handled
correctly and break parsing.

There are barely any tests.

=head1 AUTHOR

Lukas Mai, C<< <l.mai at web.de> >>
Dmitry Karasik , C<< <dmitry at karasik.eu.org >>

=head1 COPYRIGHT & LICENSE

Copyright (C) 2012, 2013 Lukas Mai.
Copyright (C) 2018 Dmitry Karasik

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut
