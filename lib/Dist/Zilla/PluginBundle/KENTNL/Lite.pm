use strict;
use warnings;
package Dist::Zilla::PluginBundle::KENTNL::Lite;

# ABSTRACT: A Minimal Build-Only replacement for @KENTNL for contributors.
#

=head1 DESCRIPTION

This is an attempt at one way of solving a common problem when contributing to things built with L<< C<Dist::Zilla>|Dist::Zilla >>.

This is done by assuming that the code base that its targeting will B<NEVER> be released in its built form,
but close enough to the normal build method that it's suitable for testing and contributing.

=over 4

=item * Less install time dependencies

=item * More phases in the pluginbundle generation are 'optional'

=item * Less points of failure

=back

Good examples of things I've experienced in this category are the 2 following ( But awesome ) plugins that I use everywhere.

=head2 L<< The C<::Git> Plugins|Dist::Zilla::Plugin::Git >>

These plugins are great, don't get me wrong, but they pose a barrier for people on Win32, and in fact, anyone without a copy of Git installed,
( Its hard enough getting a copy of the pre-release source without Git, but thats available in tar.gz and .zip on github ).

Woring Copies of Git plugins are also nonessential if you're not building releases.

=head2 L<< The C<::Twitter> Plugin|Dist::Zilla::Plugin::Twitter >>

Also, a handy plugin to have, but you're not going to be needing it unless you're tweating a realease, and usually,
that means you're me.

Some of its dependencies have been known to fail tests on Windows platforms, and thus block automatic installation, so seeing you don't have any use
for this, its sensible to leave it out.

=cut

1;
