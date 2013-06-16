
use strict;
use warnings;

use 5.010_000;

use ExtUtils::MakeMaker 6.30;

use File::ShareDir::Install;
install_share dist => "share";


my %WriteMakefileArgs = (
  "ABSTRACT" => "Notification queue for Zabbix, Nagios, et.al.",
  "AUTHOR" => "Dominik Schulz <tex\@cpan.org>",
  "BUILD_REQUIRES" => {},
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30",
    "File::ShareDir::Install" => "0.03"
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
    "Config::Yak" => 0,
    "DBD::SQLite" => 0,
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
  "TEST_REQUIRES" => {},
  "VERSION" => "0.04",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  my $tr = delete $WriteMakefileArgs{TEST_REQUIRES};
  my $br = $WriteMakefileArgs{BUILD_REQUIRES};
  for my $mod ( keys %$tr ) {
    if ( exists $br->{$mod} ) {
      $br->{$mod} = $tr->{$mod} if $tr->{$mod} > $br->{$mod};
    }
    else {
      $br->{$mod} = $tr->{$mod};
    }
  }
}

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

{
package
MY;
use File::ShareDir::Install qw(postamble);
}


