
use strict;
use warnings;

use 5.010_000;

use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "DB handling",
  "AUTHOR" => "Dominik Schulz <tex\@cpan.org>",
  "BUILD_REQUIRES" => {},
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Monitoring-Spooler",
  "EXE_FILES" => [
    "bin/mon-spooler-api.cgi",
    "bin/mon-spooler.psgi",
    "bin/mon-spooler.pl",
    "bin/mon-spooler-api.psgi",
    "bin/mon-spooler.cgi"
  ],
  "LICENSE" => "perl",
  "NAME" => "Monitoring::Spooler",
  "PREREQ_PM" => {
    "Config::Tree" => 0,
    "DBI" => 0,
    "File::ShareDir" => 0,
    "File::Temp" => 0,
    "HTTP::Cookies" => 0,
    "IPC::Open2" => 0,
    "JSON" => 0,
    "LWP::UserAgent" => 0,
    "Log::Tree" => 0,
    "Log::Tree::RequiredLogger" => 0,
    "Module::Pluggable::Object" => 0,
    "Moose" => 0,
    "MooseX::App::Cmd" => 0,
    "MooseX::App::Cmd::Command" => 0,
    "Plack::Builder" => 0,
    "Plack::Loader" => 0,
    "Plack::Request" => 0,
    "Proc::ProcessTable" => 0,
    "SMS::Send" => 0,
    "Template" => 0,
    "Try::Tiny" => 0,
    "URI::Escape" => 0,
    "XMLRPC::Lite" => 0,
    "feature" => 0,
    "mro" => 0,
    "namespace::autoclean" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "VERSION" => "0.01",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



