#!/usr/bin/perl -w

# Load test the Perl::Signature module

use strict;
use lib ();
use UNIVERSAL 'isa';
use File::Spec::Functions ':ALL';
BEGIN {
	$| = 1;
	unless ( $ENV{HARNESS_ACTIVE} ) {
		require FindBin;
		$FindBin::Bin = $FindBin::Bin; # Avoid a warning
		chdir catdir( $FindBin::Bin, updir() );
		lib->import('blib', 'lib');
	}
}

use Test::More tests => 23;
use File::Copy;
use Perl::Signature;
use PPI;

my $basic   = catfile( 't.data', 'basic.pl'   );
my $changed = catfile( 't.data', 'changed.pl' );
my $object  = catfile( 't.data', 'object.pl'  );


# Basics
my $Document = PPI::Document->new('my $foo = bar();');
isa_ok( $Document, 'PPI::Document' );
my $docsig1 = Perl::Signature->document_signature( $Document );
ok( defined $docsig1, '->document_signature returns defined' );
is( length($docsig1), 32, '->document_signature returns a 32 char thing' );
ok( $docsig1 =~ /^[abcdef01234567890]{32}$/, 'Signature is a hexidecimal string' );

my $source = ' my $foo= bar(); # comment';
my $docsig2 = Perl::Signature->source_signature( $source );
ok( defined $docsig2, '->source_signature returns defined' );
is( length($docsig2), 32, '->source_signature returns a 32 char thing' );

my $docsig3 = Perl::Signature->file_signature( $basic );
ok( defined $docsig3, '->source_signature returns defined' );
is( length($docsig3), 32, '->source_signature returns a 32 char thing' );

is( $docsig1, $docsig2, 'Document and source signatures match' );
is( $docsig1, $docsig3, 'Document and file signatures match' );

open( FILE, ">$object" ) or die "Failed to open object file";
print FILE 'my $foo = bar();';
close FILE;

# Create the object
my $Signature = Perl::Signature->new( $object );
isa_ok( $Signature, 'Perl::Signature' );
is( $Signature->file, $object, '->file matches expected' );
is( $Signature->original, $docsig1, '->original matches expected' );
is( $Signature->current, $docsig1, '->current matches expected' );
is( $Signature->changed, '', '->changed returns false' );
is( $Signature->unchanged, 1, '->unchanged returns true' );

# Change the file
open( FILE, ">$object" ) or die "Failed to open object file";
print FILE "print 'Hello World!';";
close FILE;

# Now check the object's methods again
is( $Signature->file, $object, '->file matches expected' );
is( $Signature->original, $docsig1, '->original matches expected' );
is( length($Signature->current), 32, '->current is a signature' );
ok( $Signature->current =~ /^[abcdef01234567890]{32}$/, 'Signature is a hexidecimal string' );
isnt( $Signature->current, $Signature->original, '->current matches expected' );
is( $Signature->changed, 1, '->changed returns true' );
is( $Signature->unchanged, '', '->unchanged returns false' );

END {
	unlink $object if -f $object;
}

1;
