use inc::Module::Install;

name          ( 'Perl-Signature'               );
abstract      ( 'Create functional signatures for Perl documents' );
author        ( 'Adam Kennedy<cpan@ali.as>'    );
version_from  ( 'lib/Perl/Signature.pm'        );
license       ( 'perl'                         );

requires      ( 'perl'            => '5.005'   );
requires      ( 'File::Slurp'     => '9999.04' );
requires      ( 'PPI'             => '0.829'   );
requires      ( 'Perl::Compare'   => '0.07'    );
requires      ( 'Storable'        => '2.11'    );
requires      ( 'Digest::MD5'     => '2.30'    );

build_requires( 'Test::More'      => '0.47'    );
build_requires( 'File::Spec'      => '0.82'    );

auto_install();

&WriteAll;
