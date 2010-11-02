use strict;
use warnings;

package Dist::Zilla::PluginBundle::KENTNL::Lite;

# ABSTRACT: A Minimal Build-Only replacement for @KENTNL for contributors.

=head1 SYNOPSIS

    -[@KENTNL]
    +[@KENTNL::Lite]

    dzil build
    dzil test
    dzil release # BANG.

=head1 DESCRIPTION

This is an attempt at one way of solving a common problem when contributing to things built with L<< C<Dist::Zilla>|Dist::Zilla >>.

This is done by assuming that the code base that its targeting will B<NEVER> be released in its built form,
but close enough to the normal build method that it's suitable for testing and contributing.

=over 4

=item * Less install time dependencies

=item * More phases in the C<PluginBundle> generation are 'optional'

=item * Less points of failure

=back

Good examples of things I've experienced in this category are the 2 following ( But awesome ) plug-ins that I use everywhere.

=head2 L<< The C<::Git> Plug-ins|Dist::Zilla::Plugin::Git >>

These plug-ins are great, don't get me wrong, but they pose a barrier for people on Win32, and in fact, anyone without a copy of Git installed,
( Its hard enough getting a copy of the pre-release source without Git, but that's available in C<tar.gz> and C<.zip> on C<github> ).

Working Copies of Git plug-ins are also nonessential if you're not building releases.

=head2 L<< The C<::Twitter> Plug-in|Dist::Zilla::Plugin::Twitter >>

Also, a handy plug-in to have, but you're not going to be needing it unless you're tweeting a release, and usually,
that means you're me.

Some of its dependencies have been known to fail tests on Windows platforms, and thus block automatic installation, so seeing you don't have any use
for this, its sensible to leave it out.

=cut

use Moose;

with 'Dist::Zilla::Role::PluginBundle';

use namespace::autoclean -also => [qw( _expand _load _defined_or _maybe )];

sub _expand {
  my ( $class, $suffix, $conf ) = @_;
  ## no critic ( RequireInterpolationOfMetachars )
  if ( ref $suffix ) {
    my ( $corename, $rename ) = @{$suffix};
    return [ q{@KENTNL::Lite/} . $corename . q{/} . $rename, 'Dist::Zilla::Plugin::' . $corename, $conf ];
  }
  return [ q{@KENTNL::Lite/} . $suffix, 'Dist::Zilla::Plugin::' . $suffix, $conf ];
}

sub _load {
  my $m = shift;
  eval " require $m ; 1" or do {
    ## no critic (ProhibitPunctuationVars)
    my $e = $@;
    require Carp;
    Carp::confess($e);
  };
  return;
}

=method bundle_config

See L<< the C<PluginBundle> role|Dist::Zilla::Role::PluginBundle >> for what this is for, it is a method to satisfy that role.

=cut

sub _defined_or {

  # Backcompat way of doing // in < 5.10
  my ( $hash, $field, $default, $nowarn ) = @_;
  $nowarn = 0 if not defined $nowarn;
  if ( not( defined $hash && ref $hash eq 'HASH' && exists $hash->{$field} && defined $hash->{$field} ) ) {
    require Carp;
    ## no critic (RequireInterpolationOfMetachars)
    Carp::carp( '[@KENTNL::Lite]' . " Warning: autofilling $field with $default " ) unless $nowarn;
    return $default;
  }
  return $hash->{$field};
}

sub _maybe {
  my ( $module, @passthrough ) = @_;
  if ( eval "require Dist::Zilla::Plugin::$module; 1" ) {
    return @passthrough;
  }
  require Carp;
  Carp::carp( q{[} . q[@] . q{KENTNL::Lite] Skipping _maybe dep } . $module );
  return ();
}

sub bundle_config {
  my ( $self, $section ) = @_;
  my $class = ( ref $self ) || $self;

  # NO RELEASING. KTHX.
  ## no critic ( Variables::RequireLocalizedPunctuationVars )
  $ENV{DZIL_FAKERELEASE_FAIL} = 1;

  my $arg = $section->{payload};

  my @config = map { _expand( $class, $_->[0], $_->[1] ) } (
    [
      'AutoVersion::Relative' => {
        major     => _defined_or( $arg, version_major         => 0 ),
        minor     => _defined_or( $arg, version_minor         => 1 ),
        year      => _defined_or( $arg, version_rel_year      => 2010 ),
        month     => _defined_or( $arg, version_rel_month     => 5 ),
        day       => _defined_or( $arg, version_rel_day       => 16 ),
        hour      => _defined_or( $arg, version_rel_hour      => 20 ),
        time_zone => _defined_or( $arg, version_rel_time_zone => 'Pacific/Auckland' ),
      }
    ],
    [ 'GatherDir'  => {} ],
    [ 'MetaConfig' => {} ],
    [ 'PruneCruft' => {} ],
    _maybe( 'GithubMeta', [ 'GithubMeta' => {} ] ),
    [ 'License'    => {} ],
    [ 'PkgVersion' => {} ],
    [ 'PodWeaver'  => {} ],
    _maybe( 'MetaProvides::Package', [ 'MetaProvides::Package' => {} ] ),
    [ 'MetaJSON'    => {} ],
    [ 'MetaYAML'    => {} ],
    [ 'ModuleBuild' => {} ],
    _maybe( 'ReadmeFromPod', [ 'ReadmeFromPod' => {} ], ),
    [ 'ManifestSkip' => {} ],
    [ 'Manifest'     => {} ],
    [ 'AutoPrereqs'   => {} ],
    _maybe( 'MetaData::BuiltWith', [ 'MetaData::BuiltWith' => { show_uname => 1, uname_args => q{ -s -o -r -m -i } } ], ),
    [ 'CompileTests'     => {} ],
    _maybe( 'CriticTests', [ 'CriticTests' => {} ] ),
    [ 'MetaTests'        => {} ],
    [ 'PodCoverageTests' => {} ],
    [ 'PodSyntaxTests'   => {} ],
    _maybe( 'ReportVersions::Tiny', [ 'ReportVersions::Tiny' => {} ], ),
    _maybe( 'KwaliteeTests',        [ 'KwaliteeTests'        => {} ] ),
    [ 'PortabilityTests' => {} ],
    [ 'EOLTests'         => { trailing_whitespace => 1, } ],
    [ 'ExtraTests'       => {} ],
    [ 'TestRelease'      => {} ],
    [ 'FakeRelease'      => {} ],
    [ 'NextRelease'      => {} ],
  );
  _load( $_->[1] ) for @config;
  return @config;
}
__PACKAGE__->meta->make_immutable;
no Moose;

## no critic (RequireEndWithOne)
'Thankyou for flying with KENTNL Lite!';

