use inc::Module::Install;

name          ( 'Perl-Signature'            );
abstract      ( 'Generate functional signatures for Perl source code' );
author        ( 'Adam Kennedy<cpan@ali.as>' );
version_from  ( 'lib/Perl/Signature.pm'     );
license       ( 'perl'                      );

requires      ( 'perl'          => '5.005'  );
requires      ( 'Storable'      => '2.11'   );
requires      ( 'Digest::MD5'   => '2.30'   );
requires      ( 'Config::Tiny'  => '2.00'   );
requires      ( 'PPI'           => '0.902'  );

build_requires( 'Test::More'    => '0.47'   );
build_requires( 'File::Spec'    => '0.82'   );

# Our test data might contain valid-looking modules.
# Don't index anything in the test data directory.
no_index      ( directory       => 't.data' );

auto_install();

&WriteAll;
