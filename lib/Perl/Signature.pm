package Perl::Signature;

=pod

=head1 NAME

Perl::Signature - Generate functional signatures for perl code

=head2 DESCRIPTION

A large part of the work in creating Perl::Compare was put into it's method
for "normalizing" perl code as far as possible.

However, the main problem in working with these normalised files is that we
need to do a relatively expensive deep compare of a very large data
structure.

Perl::Signature attempts to resolve this problem by taking the normalized
perl document, serialising it via a standard serialization mechanism, and
then digesting it down to a single 128-bit signature.

This is a fairly expensive process, mainly because it involves a full PPI
parse round, the normalization process, serialization, and digesting.

But, having done it for a file once, you can do a direct comparison to the
functional signature of any other file, and if they match, then it's a
pretty safe bet they are functionally the same.

=head2 Avoid Changes in the Calculation

Perl::Signature is relatively sensitive. Because any file goes through 4
stages, any of which could change in structure with an upgrade, you should
ensure that all signatures are generated with the same versions of
L<PPI|PPI>, L<Perl::Compare> and the same set of Perl::Compare plugins
installed.

=head1 METHODS

Because most of the work is done elsewhere, all the methods are one-shot
methods. They will all either return a 32 character hexidecimal MD5 hash,
or C<undef>.

=cut

use strict;
use UNIVERSAL 'isa';
use File::Slurp   ();
use PPI           ();
use Perl::Compare ();
use Storable      ();
use Digest::MD5   ();

use vars qw{$VERSION};
BEGIN {
	$VERSION = '0.01';
}





#####################################################################
# Main Methods

=pod

=head2 file $filename

The C<file> method does the whole deal. Load a file, parse it, normalize,
serialize and digest. It actually happens in several parts. C<file> just
loads the file and passes it on to C<source>.

Returns a 32 character hexidecimal MD5 signature.

=cut

sub file {
	my $class = shift;
	my $filename = -f $_[0] ? shift : return undef;
	my $source = File::Slurp::read_file( $filename, scalar_ref => 1 );
	$class->source( $source );
}

=pod

=head2 source $content | \$content

The C<source> takes perl source code as either a plain string or a
reference to a SCALAR. Parses the content and hands the
L<PPI::Document|PPI::Document> object off to C<Document>.

Returns a 32 character hexidecimal MD5 signature.

=cut

sub source {
	my $class = shift;
	my $source = defined $_[0] ? shift : return undef;
	$source = $$source if ref $source;

	# Build the PPI::Document
	my $Document = PPI::Lexer->lex_source( $source );
	$class->Document( $Document );
}

=pod

=head2 Document

The C<Document> method takes a PPI::Document object and does the final
nomalize + serialize + digest steps.

Returns a 32 character hexidecimal MD5 signature.

=cut

sub Document {
	my $class = shift;
	my $Document = isa(ref $_[0], 'PPI::Document') ? shift : return undef;

	# Normalize the PPI::Document
	my $rv = Perl::Compare->normalize( $Document );
	return undef unless defined $rv;

	# Freeze the NormalizedDocument
	my $string = Storable::freeze $Document;
	return undef unless defined $string;

	# Last step, hash the string
	Digest::MD5::md5_hex( $string ) or undef;
}

1;

=pod

=head1 TO DO

- Write unit tests

- Test test test

=head1 SUPPORT

All bugs should be filed via the CPAN bug tracker at

L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Perl%3A%3ASignature>

For other issues, contact the author

=head1 AUTHORS

Adam Kennedy (Maintainer), L<http://ali.as/>, cpan@ali.as

=head1 COPYRIGHT

Copyright (c) 2004 Adam Kennedy. All rights reserved.
This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut
