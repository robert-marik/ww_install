package Linux::Distribution;

use 5.006000;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

our @EXPORT_OK = qw( distribution_name distribution_version );

our $VERSION = '0.14';

our $standard_release_file = 'lsb-release';

our %release_files = (
    'centos-release'        => 'centos',
    'gentoo-release'        => 'gentoo',
    'fedora-release'        => 'fedora',
    'turbolinux-release'    => 'turbolinux',
    'mandrake-release'      => 'mandrake',
    'mandrakelinux-release' => 'mandrakelinux',
    'debian_version'        => 'debian',
    'debian_release'        => 'debian',
    'SuSE-release'          => 'suse',
    'knoppix-version'       => 'knoppix',
    'yellowdog-release'     => 'yellowdog',
    'slackware-version'     => 'slackware',
    'slackware-release'     => 'slackware',
    'redflag-release'       => 'redflag',
    'redhat-release'        => 'redhat',
    'redhat_version'        => 'redhat',
    'conectiva-release'     => 'conectiva',
    'immunix-release'       => 'immunix',
    'tinysofa-release'      => 'tinysofa',
    'trustix-release'       => 'trustix',
    'adamantix_version'     => 'adamantix',
    'yoper-release'         => 'yoper',
    'arch-release'          => 'arch',
    'libranet_version'      => 'libranet',
    'va-release'            => 'va-linux'
);

our %version_match = (
    'gentoo'                => 'Gentoo Base System version (.*)',
    'centos'                => 'CentOS (?:Linux )?release (\d+)\..*',
    'debian'                => '(\d*).*',
    'suse'                  => 'VERSION = (.*)',
    'fedora'                => 'Fedora (?:Core )?release (\d+) \(',
    'redflag'               => 'Red Flag (?:Desktop|Linux) (?:release |\()(.*?)(?: \(.+)?\)',
    'redhat'                => 'Red Hat (?:Enterprise) Linux (?:Server) release (.*) \(',
    'slackware'             => '^Slackware (.+)$'
);


if ($^O ne 'linux') {
  require Carp;
	Carp::croak('you are trying to use a linux specific module on a different OS');
}

sub new {
    my %self = (
        'DISTRIB_ID'          => '',
        'DISTRIB_RELEASE'     => '',
        'DISTRIB_CODENAME'    => '',
        'DISTRIB_DESCRIPTION' => '',
        'release_file'        => '',
        'pattern'             => ''
    );
    
    return bless \%self;
}

sub distribution_name {
    my $self = shift || new();
    my $distro;
    if ($distro = $self->_get_lsb_info()){
        return $distro if ($distro);
    }
    foreach (keys %release_files) {
        if (-f "/etc/$_" && !-l "/etc/$_"){
            if (-f "/etc/$_" && !-l "/etc/$_"){
                $self->{'DISTRIB_ID'} = $release_files{$_};
                $self->{'release_file'} = $_;
                return $self->{'DISTRIB_ID'};
            }
        }
    }
    undef 
}

sub distribution_version {
    my $self = shift || new();
    my $release;
    return $release if ($release = $self->_get_lsb_info('DISTRIB_RELEASE'));
    if (! $self->{'DISTRIB_ID'}){
         $self->distribution_name() or die 'No version because no distro.';
    }
    $self->{'pattern'} = $version_match{$self->{'DISTRIB_ID'}};
    $release = $self->_get_file_info();
    $self->{'DISTRIB_RELEASE'} = $release;
    return $release;
}

sub _get_lsb_info {
    my $self = shift;
    my $field = shift || 'DISTRIB_ID';
    my $tmp = $self->{'release_file'};
    if ( -r '/etc/' . $standard_release_file ) {
        $self->{'release_file'} = $standard_release_file;
        $self->{'pattern'} = $field . '=(.+)';
        my $info = $self->_get_file_info();
        if ($info){
            $self->{$field} = $info;
            return $info
        }
    } 
    $self->{'release_file'} = $tmp;
    $self->{'pattern'} = '';
    undef;
}

sub _get_file_info {
    my $self = shift;
    open FH, '/etc/' . $self->{'release_file'} or die 'Cannot open file: /etc/' . $self->{'release_file'};
    my $info = '';
    while (<FH>){
        chomp $_;
        ($info) = $_ =~ m/$self->{'pattern'}/;
        return "\L$info" if $info;
    }
    undef;
}

1;
__END__


=head1 NAME

Linux::Distribution - Perl extension to guess on which Linux distribution we are running.

=head1 SYNOPSIS

  use Linux::Distribution qw(distribution_name distribution_version);

  if(my $distro = distribution_name) {
        my $version = distribution_version();
  	print "you are running $distro, version $version\n";
  } else {
  	print "distribution unknown\n";
  }

  Or else do it OO:

  use Linux::Distribution qw(distribution_name distribution_version);

  $linux = new Linux::Distribution;
  if(my $distro = $linux->distribution_name()) {
        my $version = $linux->distribution_version();
        print "you are running $distro, version $version\n";
  } else {
        print "distribution unknown\n";
  }

=head1 DESCRIPTION

This is a simple module that tries to guess on what linux distribution we are running by looking for release's files in /etc.  It now looks for 'lsb-release' first as that should be the most correct and adds ubuntu support.  Secondly, it will look for the distro specific files.

It currently recognizes slackware, debian, suse, fedora, redhat, turbolinux, yellowdog, knoppix, mandrake, conectiva, immunix, tinysofa, va-linux, trustix, adamantix, yoper, arch-linux, libranet, gentoo, ubuntu and redflag.

It has function to get the version for debian, suse, redhat, gentoo, slackware, redflag and ubuntu(lsb). People running unsupported distro's are greatly encouraged to submit patches :-)

=head2 EXPORT

None by default.

=head1 TODO

Add the capability of recognize the version of the distribution for all recognized distributions.

=head1 AUTHORS

Alberto Re, E<lt>alberto@accidia.netE<gt>
Judith Lebzelter, E<lt>judith@osdl.orgE<gt>

=head1 COPYRIGHT AND LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.5 or,
at your option, any later version of Perl 5 you may have available.

=cut

