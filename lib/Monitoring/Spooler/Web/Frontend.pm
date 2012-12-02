package Monitoring::Spooler::Web::Frontend;
{
  $Monitoring::Spooler::Web::Frontend::VERSION = '0.02';
}
BEGIN {
  $Monitoring::Spooler::Web::Frontend::AUTHORITY = 'cpan:TEX';
}
# ABSTRACT: the plack endpoint for the webinterface

use 5.010_000;
use mro 'c3';
use feature ':5.10';

use Moose;
use namespace::autoclean;

# use IO::Handle;
# use autodie;
# use MooseX::Params::Validate;
# use Carp;
# use English qw( -no_match_vars );
# use Try::Tiny;
use Template;
use File::ShareDir;

# extends ...
extends 'Monitoring::Spooler::Web';
# has ...
has 'tt' => (
    'is'      => 'ro',
    'isa'     => 'Template',
    'lazy'    => 1,
    'builder' => '_init_tt',
);
# with ...
# initializers ...
sub _init_tt {
    my $self = shift;

    my $dist_dir = File::ShareDir::dist_dir('Monitoring-Spooler');
    my @inc = ( 'share/tpl', '../share/tpl', );
    if(-d $dist_dir) {
        push(@inc, $dist_dir.'/tpl');
    }
    my $cfg_dir = $self->config()->get('Monitoring::Spooler::Frontend::TemplatePath');
    if(-d $cfg_dir) {
        unshift(@inc,$cfg_dir);
    }

    my $tpl_config = {
        INCLUDE_PATH => [ @inc, ],
        POST_CHOMP   => 1,
        FILTERS      => {
            'substr'   => [
                sub {
                    my ( $context, $len ) = @_;

                    return sub {
                        my $str = shift;
                        if ($len) {
                            $str = substr $str, 0, $len;
                        }
                        return $str;
                      }
                },
                1,
            ],
            'ucfirst'       => sub { my $str = shift; return ucfirst($str); },
            'localtime'     => sub { my $str = shift; return localtime($str); },
        },
    };
    my $TT = Template::->new($tpl_config);

    return $TT;
}

sub _init_fields {
    return [qw(rm group_id msg_id message type)];
}

# your code here ...
sub _handle_request {
    my $self = shift;
    my $request = shift;

    my $mode = $request->{'rm'};

    if(!$mode || $mode eq 'overview') {
        return $self->_handle_overview($request);
    } elsif($mode eq 'add_message') {
        return $self->_handle_add_message($request);
    } elsif($mode eq 'flush_messages') {
        return $self->_handle_flush_messages($request);
    } elsif($mode eq 'rm_message') {
        return $self->_handle_rm_message($request);
    } else {
        return;
    }
}

sub _handle_overview {
    my $self = shift;
    my $request = shift;

    my %groups = ();
    my $sql = 'SELECT id,name FROM groups ORDER BY name';
    my $sth = $self->dbh()->prepare($sql);
    if($sth) {
        if($sth->execute()) {
            while(my ($id,$name) = $sth->fetchrow_array()) {
                $groups{$id}->{'name'} = $name;
            }
            $sth->finish();
        } else {
            $self->logger()->log( message => 'Failed to execute statement w/ error: '.$sth->errstr, level => 'warning', );
            return [ 500, [ 'Content-Type', 'text/plain'], ['Internal Server Error']];
        }
    } else {
        $self->logger()->log( message => 'Failed to prepare statement from SQL: '.$sql.' w/ error: '.$self->dbh()->errstr, level => 'warning', );
        return [ 500, [ 'Content-Type', 'text/plain'], ['Internal Server Error']];
    }

    $sql = 'SELECT id,group_id,type,message,ts,event,trigger_id FROM msg_queue ORDER BY id';
    $sth = $self->dbh()->prepare($sql);
    if($sth) {
        if($sth->execute()) {
            while(my ($id,$group_id,$type,$message,$ts,$event,$trigger_id) = $sth->fetchrow_array()) {
                push(@{$groups{$group_id}->{'msg_queue'}}, {
                    'id' => $id,
                    'type'  => $type,
                    'message' => $message,
                    'ts' => $ts,
                    'event' => $event,
                    'trigger_id' => $trigger_id,
                });
            }
            $sth->finish();
        } else {
            $self->logger()->log( message => 'Failed to execute statement w/ error: '.$sth->errstr, level => 'warning', );
            return [ 500, [ 'Content-Type', 'text/plain'], ['Internal Server Error']];
        }
    } else {
        $self->logger()->log( message => 'Failed to prepare statement from SQL: '.$sql.' w/ error: '.$self->dbh()->errstr, level => 'warning', );
        return [ 500, [ 'Content-Type', 'text/plain'], ['Internal Server Error']];
    }

    $sql = 'SELECT id,group_id,name,number FROM notify_order ORDER BY id';
    $sth = $self->dbh()->prepare($sql);
    if($sth) {
        if($sth->execute()) {
            while(my ($id,$group_id,$name,$number) = $sth->fetchrow_array()) {
                push(@{$groups{$group_id}->{'notify_queue'}}, {
                    'id' => $id,
                    'name'  => $name,
                    'number' => $number,
                });
            }
            $sth->finish();
        } else {
            $self->logger()->log( message => 'Failed to execute statement w/ error: '.$sth->errstr, level => 'warning', );
            return [ 500, [ 'Content-Type', 'text/plain'], ['Internal Server Error']];
        }
    } else {
        $self->logger()->log( message => 'Failed to prepare statement from SQL: '.$sql.' w/ error: '.$self->dbh()->errstr, level => 'warning', );
        return [ 500, [ 'Content-Type', 'text/plain'], ['Internal Server Error']];
    }

    $sql = 'SELECT id,group_id,until FROM paused_groups';
    $sth = $self->dbh()->prepare($sql);
    if($sth) {
        if($sth->execute()) {
            while(my ($id,$group_id,$until) = $sth->fetchrow_array()) {
                if(!$groups{$group_id}->{'paused_until'} || ($groups{$group_id}->{'paused_until'} && $groups{$group_id}->{'paused_until'} < $until) ) {
                    $groups{$group_id}->{'paused_until'} = $until;
                }
            }
            $sth->finish();
        } else {
            $self->logger()->log( message => 'Failed to execute statement w/ error: '.$sth->errstr, level => 'warning', );
            return [ 500, [ 'Content-Type', 'text/plain'], ['Internal Server Error']];
        }
    } else {
        $self->logger()->log( message => 'Failed to prepare statement from SQL: '.$sql.' w/ error: '.$self->dbh()->errstr, level => 'warning', );
        return [ 500, [ 'Content-Type', 'text/plain'], ['Internal Server Error']];
    }

    my @running_procs = ();
    $sql = 'SELECT pid,type,name FROM running_procs';
    $sth = $self->dbh()->prepare($sql);
    if($sth) {
        if($sth->execute()) {
            while(my ($pid,$type,$name) = $sth->fetchrow_array()) {
                push(@running_procs, {
                    'pid' => $pid,
                    'type' => $type,
                    'name' => $name,
                });
            }
            $sth->finish();
        } else {
            $self->logger()->log( message => 'Failed to execute statement w/ error: '.$sth->errstr, level => 'warning', );
            return [ 500, [ 'Content-Type', 'text/plain'], ['Internal Server Error']];
        }
    } else {
        $self->logger()->log( message => 'Failed to prepare statement from SQL: '.$sql.' w/ error: '.$self->dbh()->errstr, level => 'warning', );
        return [ 500, [ 'Content-Type', 'text/plain'], ['Internal Server Error']];
    }

    $sql = 'SELECT id,group_id,type,notify_from,notify_to FROM notify_interval ORDER BY id';
    $sth = $self->dbh()->prepare($sql);
    if($sth) {
        if($sth->execute()) {
            while(my ($id,$group_id,$type,$notify_from,$notify_to) = $sth->fetchrow_array()) {
                push(@{ $groups{$group_id}->{'notify_intervals'} }, {
                    'id' => $id,
                    'type'  => $type,
                    'notify_from' => $notify_from,
                    'notify_to' => $notify_to,
                });
            }
            $sth->finish();
        } else {
            $self->logger()->log( message => 'Failed to execute statement w/ error: '.$sth->errstr, level => 'warning', );
            return [ 500, [ 'Content-Type', 'text/plain'], ['Internal Server Error']];
        }
    } else {
        $self->logger()->log( message => 'Failed to prepare statement from SQL: '.$sql.' w/ error: '.$self->dbh()->errstr, level => 'warning', );
        return [ 500, [ 'Content-Type', 'text/plain'], ['Internal Server Error']];
    }

    my $body;
    $self->tt()->process(
        'overview.tpl',
        {
            'groups'         => \%groups,
            'running_proces' => \@running_procs,
        },
        \$body,
    ) or $self->logger()->log( message => 'TT error: '.$self->tt()->error, level => 'warning', );

    return [ 200, [ 'Content-Type', 'text/html' ], [$body]];
}

sub _handle_add_message {
    my $self = shift;
    my $request = shift;

    my $group_id = $request->{'group_id'};
    my $message  = $request->{'message'};
    my $type     = $request->{'type'} || 'text';

    if($group_id && $message) {
        my $sql = 'INSERT INTO msg_queue (group_id,type,message,ts,event,trigger_id) VALUES(?,?,?,?,?,?)';
        my $sth = $self->dbh()->prepexec($group_id,$type,$message,time(),'',0);
        $sth->finish() if $sth;
    }

    return [ 301, [ 'Location', '?rm=overview' ], [] ];
}

sub _handle_rm_message {
    my $self = shift;
    my $request = shift;

    my $message_id = $request->{'msg_id'};

    if($message_id) {
        my $sql = 'DELETE FROM msg_queue WHERE id = ?';
        my $sth = $self->dbh()->prepexec($sql,$message_id);
        $sth->finish() if $sth;
    }

    return [ 301, [ 'Location', '?rm=overview' ], [] ];
}

sub _handle_flush_messages {
    my $self = shift;
    my $request = shift;

    my $group_id = $request->{'group_id'} || 0;

    my $sql = 'DELETE FROM msg_queue';
    my @args = ();
    if($group_id) {
        $sql .= ' WHERE group_id = ?';
        push(@args,$group_id);
    }
    my $sth = $self->dbh()->prepexec($sql,@args);
    $sth->finish() if $sth;

    return [ 301, [ 'Location', '?rm=overview' ], [] ];
}
# TODO allow mgmt of groups
# TODO allow mgmt of pauses

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=encoding utf-8

=head1 NAME

Monitoring::Spooler::Web::Frontend - the plack endpoint for the webinterface

=head1 NAME

Monitoring::Spooler::Web::Frontend - the web frontend implementation

=head1 AUTHOR

Dominik Schulz <tex@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Dominik Schulz.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
