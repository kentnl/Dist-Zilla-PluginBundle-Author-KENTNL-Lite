use strict;
use warnings;

package Dist::Zilla::PluginBundle::Author::KENTNL::Lite;
use Class::Load 0.06 qw( :all );

# ABSTRACT: A Minimal Build-Only replacement for @Author::KENTNL for contributors.

=head1 SYNOPSIS

    -[@Author::KENTNL]
    +[@Author::KENTNL::Lite]

    dzil build
    dzil test
    dzil release # BANG.

=head1 NAMING SCHEME

Please read my rant in L<Dist::Zilla::PluginBundle::Author::KENTNL/NAMING SCHEME> about the Author:: convention.

=cut

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
    if ( exists $conf->{-name} ) {
      $rename = delete $conf->{-name};
    }
    return [ q{@Author::KENTNL::Lite/} . $corename . q{/} . $rename, 'Dist::Zilla::Plugin::' . $corename, $conf ];
  }
   if ( exists $conf->{-name} ) {
    my $rename;
    $rename = sprintf q{%s/%s}, $suffix, ( delete $conf->{-name} );
    return [ q{@Author::KENTNL::Lite/} . $rename, 'Dist::Zilla::Plugin::' . $suffix, $conf ];

  }

  return [ q{@Author::KENTNL::Lite/} . $suffix, 'Dist::Zilla::Plugin::' . $suffix, $conf ];
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
    Carp::carp( '[@Author::KENTNL::Lite]' . " Warning: autofilling $field with $default " ) unless $nowarn;
    return $default;
  }
  return $hash->{$field};
}

sub _maybe {
  my ( $module, @passthrough ) = @_;
  if ( load_optional_class("Dist::Zilla::Plugin::$module") ) {
    return @passthrough;
  }
  require Carp;
  Carp::carp( q{[} . q[@] . q{Author::KENTNL::Lite] Skipping _maybe dep } . $module );
  return ();
}

sub _if_git_versions {
  my ( $args, $gitversions, $else ) = @_;
  if ( exists $ENV{KENTNL_GITVERSIONS} or exists $args->{git_versions} ) {
    if ( load_optional_class(q{Dist::Zilla::Plugin::Git::NextVersion}) ) {
      return @{$gitversions};
    }
    require Carp;
    Carp::confess(q{Sorry, versioning for this package needs Git::NextVersion, please install it});
  }
  return @{$else};
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
      _if_git_versions(
        $arg,
        [ 'Git::NextVersion' => { version_regexp => '^(.*)-source$', first_version => '0.1.0' } ],
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
        ]
      ),

    ],
    [ 'GatherDir'  => { include_dotfiles => 1 } ],
    [ 'MetaConfig' => {} ],
    [ 'PruneCruft' => { except           => '^.perltidyrc' } ],
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
    [ 'AutoPrereqs'  => {} ],
    [
      'Prereqs' => {
        -name                                             => 'BundleDevelNeeds',
        -phase                                            => 'develop',
        -type                                             => 'requires',
        'Dist::Zilla::PluginBundle::Author::KENTNL::Lite' => 0
      }
    ],
    [
      'Prereqs' => {
        -name                                             => 'BundleDevelRecommends',
        -phase                                            => 'develop',
        -type                                             => 'recommends',
        'Dist::Zilla::PluginBundle::Author::KENTNL::Lite' => '1.0.0'
      }
    ],
    [
      'Prereqs' => {
        -name                                       => 'BundleDevelSuggests',
        -phase                                      => 'develop',
        -type                                       => 'suggests',
        'Dist::Zilla::PluginBundle::Author::KENTNL' => '1.0.0',
      }
    ],
    _maybe( 'MetaData::BuiltWith', [ 'MetaData::BuiltWith' => { show_uname => 1, uname_args => q{ -s -o -r -m -i } } ], ),
    [ 'CompileTests' => {} ],
    _maybe( 'CriticTests', [ 'CriticTests' => {} ] ),
    [ 'MetaTests'        => {} ],
    [ 'PodCoverageTests' => {} ],
    [ 'PodSyntaxTests'   => {} ],
    _maybe( 'ReportVersions::Tiny', [ 'ReportVersions::Tiny' => {} ], ),
    _maybe( 'KwaliteeTests',        [ 'KwaliteeTests'        => {} ] ),
    [ 'EOLTests'    => { trailing_whitespace => 1, } ],
    [ 'ExtraTests'  => {} ],
    [ 'TestRelease' => {} ],
    [ 'FakeRelease' => {} ],
    [ 'NextRelease' => {} ],
  );
  load_class( $_->[1] ) for @config;
  return @config;
}
__PACKAGE__->meta->make_immutable;
no Moose;

## no critic (RequireEndWithOne)
'Thankyou for flying with KENTNL Lite!';

