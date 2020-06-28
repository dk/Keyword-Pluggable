use strict;
use warnings;
use Keyword::Pluggable;

BEGIN {
	Keyword::Pluggable::define keyword => 'try', code => 'eval';
	Keyword::Pluggable::define keyword => 'catch', code => 'if ($@)';
}

try {
	die 1;
}; catch {
	print "[$@]\n";
}
