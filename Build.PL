
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  'build_requires' => {
    'English' => '0',
    'File::Find' => '0',
    'File::Temp' => '0',
    'Module::Build' => '0.3601',
    'Test::More' => '0.88'
  },
  'configure_requires' => {
    'Module::Build' => '0.3601'
  },
  'dist_abstract' => 'A Minimal Build-Only replacement for @Author::KENTNL for contributors.',
  'dist_author' => [
    'Kent Fredric <kentnl@cpan.org>'
  ],
  'dist_name' => 'Dist-Zilla-PluginBundle-Author-KENTNL-Lite',
  'dist_version' => '1.0.0',
  'license' => 'perl',
  'module_name' => 'Dist::Zilla::PluginBundle::Author::KENTNL::Lite',
  'recommends' => {},
  'recursive_test_files' => 1,
  'requires' => {
    'Carp' => '0',
    'Class::Load' => '0.06',
    'Dist::Zilla::Plugin::AutoPrereqs' => '0',
    'Dist::Zilla::Plugin::AutoVersion::Relative' => '0',
    'Dist::Zilla::Plugin::CompileTests' => '0',
    'Dist::Zilla::Plugin::EOLTests' => '0',
    'Dist::Zilla::Plugin::ExtraTests' => '0',
    'Dist::Zilla::Plugin::FakeRelease' => '0',
    'Dist::Zilla::Plugin::GatherDir' => '0',
    'Dist::Zilla::Plugin::License' => '0',
    'Dist::Zilla::Plugin::Manifest' => '0',
    'Dist::Zilla::Plugin::ManifestSkip' => '0',
    'Dist::Zilla::Plugin::MetaConfig' => '0',
    'Dist::Zilla::Plugin::MetaJSON' => '0',
    'Dist::Zilla::Plugin::MetaTests' => '0',
    'Dist::Zilla::Plugin::MetaYAML' => '0',
    'Dist::Zilla::Plugin::ModuleBuild' => '0',
    'Dist::Zilla::Plugin::NextRelease' => '0',
    'Dist::Zilla::Plugin::PkgVersion' => '0',
    'Dist::Zilla::Plugin::PodCoverageTests' => '0',
    'Dist::Zilla::Plugin::PodSyntaxTests' => '0',
    'Dist::Zilla::Plugin::PodWeaver' => '0',
    'Dist::Zilla::Plugin::Prereqs' => '0',
    'Dist::Zilla::Plugin::PruneCruft' => '0',
    'Dist::Zilla::Plugin::TestRelease' => '0',
    'Dist::Zilla::Role::PluginBundle' => '0',
    'Moose' => '0',
    'namespace::autoclean' => '0'
  },
  'script_files' => []
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
