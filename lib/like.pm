package like;

use latest;

use Carp;

use base qw( Exporter );

our @EXPORT_OK = qw( things_like );

=head1 NAME

like - Declare support for an interface

=head1 VERSION

This document describes like version 0.03

=cut

our $VERSION = '0.03';

=head1 SYNOPSIS

  package MyThing;

  use like qw( some::interface );

  # later

  if ( MyThing->isa( 'some::interface' ) ) {
    print "Yes it is!\n";
  }
  
=head1 DESCRIPTION

Allows a package to declare that it ISA named interface without that
interface having to pre-exist.

This

  package MyThing;

  use like qw( some::interface );

is equivalent to

  package some::interface; # make the package exist

  package MyThing;

  use vars qw( @ISA );
  push @ISA, 'some::interface';

The like declaration is intended to declare that your package
conforms to some interface without needing to have the consumer of that
interface installed.

There is no test that your package really does conform to any interface
(see L<Moose>); you're just declaring your intent.

=head1 INTERFACE

=cut

sub import {
  my ( $class, @isa ) = @_;
  if ( @isa ) {
    my $caller = caller;
    no strict 'refs';
    for my $isa ( @isa ) {
      @{"${isa}::ISA"} = () unless @{"${isa}::ISA"};
    }
    push @{"${caller}::ISA"}, @isa;
  }
  return __PACKAGE__->export_to_level( 1, $class, 'things_like' );
}

=head2 C<things_like>

Get a list of classes that claim to implement a trait.

  my @t = things_like 'some::interface';

=cut

sub things_like($) {
  my $trait = shift;
  return grep $_ ne $trait && $_->isa( $trait ),
   _walk_stash( $main::{'main::'} );
}

sub _walk_stash {
  my ( $node, @path ) = @_;
  my @pkg = ();

  for my $ns ( sort grep /::$/, keys %$node ) {
    next if $ns eq 'main::';
    ( my $name = join '', @path, $ns ) =~ s/::$//;
    push @pkg, $name, _walk_stash( $node->{$ns}, @path, $ns );
  }

  return @pkg;
}

1;

__END__

=head1 CONFIGURATION AND ENVIRONMENT
  
like requires no configuration files or environment variables.

=head1 DEPENDENCIES

None.

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

Please report any bugs or feature requests to
C<bug-like@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

=head1 AUTHOR

Andy Armstrong  C<< <andy@hexten.net> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2009, Andy Armstrong C<< <andy@hexten.net> >>.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.
