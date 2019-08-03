package parent::versioned;

use strict;

our $VERSION = '0.001_01';
$VERSION = eval "$VERSION";

# Based on parent.pm, version 0.237;
# parent was included in the Perl core beginning with Perl 5.10.1,
# and is dual-lived on CPAN.

sub import {
    my $class = shift;

    my $inheritor = caller(0);

    if ( @_ and $_[0] eq '-norequire' ) {
        shift @_;
    } else {
        for ( my @filename = @_ ) {
            s{::|'}{/}g;
            require "$_.pm"; # dies if the file is not found
        }
    }

    {
        no strict 'refs';
        push @{"$inheritor\::ISA"}, @_; # dies if a loop is detected
    };
};

1;

__END__

=encoding utf8

=head1 NAME

parent::versioned - Establish an ISA relationship with base classes at compile time, with version checking.

=head1 SYNOPSIS

    package Baz;
    use parent::versioned qw(Foo Bar);

=head1 DESCRIPTION

Allows you to both load one or more modules, while setting up inheritance from
those modules at the same time.  Mostly similar in effect to

    package Baz;
    BEGIN {
        require Foo;
        require Bar;
        push @ISA, qw(Foo Bar);
    }

By default, every base class needs to live in a file of its own.
If you want to have a subclass and its parent class in the same file, you
can tell C<parent::versioned> not to load any modules by using the C<-norequire> switch:

  package Foo;
  sub exclaim { "I CAN HAS PERL" }

  package DoesNotLoadFooBar;
  use parent::versioned -norequire, 'Foo', 'Bar';
  # will not go looking for Foo.pm or Bar.pm

This is equivalent to the following code:

  package Foo;
  sub exclaim { "I CAN HAS PERL" }

  package DoesNotLoadFooBar;
  push @DoesNotLoadFooBar::ISA, 'Foo', 'Bar';

This is also helpful for the case where a package lives within
a differently named file:

  package MyHash;
  use Tie::Hash;
  use parent::versioned -norequire, 'Tie::StdHash';

This is equivalent to the following code:

  package MyHash;
  require Tie::Hash;
  push @ISA, 'Tie::StdHash';

If you want to load a subclass from a file that C<require> would
not consider an eligible filename (that is, it does not end in
either C<.pm> or C<.pmc>), use the following code:

  package MySecondPlugin;
  require './plugins/custom.plugin'; # contains Plugin::Custom
  use parent::versioned -norequire, 'Plugin::Custom';

=head1 HISTORY

This module was forked from L<parent>, which itself was forked from
L<base> to remove the cruft that had accumulated in it.

=head1 CAVEATS

=head1 SEE ALSO

=over 4

=item L<parent>

=item L<base>

=back

=head1 AUTHORS AND CONTRIBUTORS

David Oswald forked this module from L<parent> and added version checking.

L<parent> was authored by Rafaël Garcia-Suarez, Bart Lateur, Max Maischein,
Anno Siegel, and Michael Schwern.

=head1 MAINTAINER

David Oswald C< davido@cpan.org >

Copyright (c) 2019 David Oswald C<< <davido@cpan.org> >>.

Based on a fork from L<parent>, which is maintained
by Max Maischein C<< <corion@cpan.org> >>, and was introduced to the
Perl core with Perl 5.10.1.

=head1 LICENSE

This module is released under the same terms as Perl itself.

=cut
