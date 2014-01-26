package Net::UPS::StreetAddress;
use strict;
use Carp;
use XML::Simple;
use Class::Struct;

struct(
    quality             => '$',
    name                => '$',
    address             => '$',
    address2            => '$',
    city                => '$',
    postal_code         => '$',
    state               => '$',
    country_code        => '$',
    is_residential      => '$'
);

*is_exact_match = \&is_match;
sub is_match {
    my $self = shift;
    return unless $self->quality();
    return ($self->quality == 1);
}

sub as_hash {
    my $self = shift;
    unless ( defined $self->postal_code ) {
        croak "as_string(): 'postal_code' is empty";
    }
    my %data = (
        AddressKeyFormat => {
            CountryCode => $self->country_code || "US",
            PostcodePrimaryLow  => $self->postal_code,
        }
    );
    if ( defined $self->name ) {
           $data{AddressKeyFormat}->{ConsigneeName} = $self->name();
    }
    if ( defined $self->address ) {
           $data{AddressKeyFormat}->{AddressLine} = $self->address();
    }
    if ( defined $self->address2 ) {
        $data{AddressKeyFormat}->{BuildingName} = $self->address2();
    }
    if ( defined $self->city ) {
        $data{AddressKeyFormat}->{PoliticalDivision2} = $self->city();
    }
    if ( defined $self->state ) {
        $data{AddressKeyFormat}->{PoliticalDivision1} = $self->state_province_code;
    }
    return \%data;
}


sub as_XML {
    my $self = shift;
    return XMLout( $self->data, NoAttr=>1, KeepRoot=>1, SuppressEmpty=>1 )
}




sub cache_id { return $_[0]->postal_code }





sub validate {
    my $self = shift;
    my $args = shift || {};

    require Net::UPS;
    my $ups = Net::UPS->instance();
    return $ups->validate_street_address($self, $args);
}






1;

__END__;

=head1 NAME

Net::UPS::StreetAddress - Shipping address class for street level requests

=head1 SYNOPSIS

    use Net::UPS::StreetAddress;
    my $address = Net::UPS::StreetAddress->new();
    $address->name("John Doe");
    $address->address("123 Test Street");
    $address->city("New York");
    $address->state("NY");
    $address->postal_code("10007");
    $address->country_code("US");

=head1 DESCRIPTION

Net::UPS::StreetAddress is a class representing a shipping address. Valid address attributes are C<address>, C<address2>, C<city>, C<state>, C<postal_code>, and C<country_code>.

If address was run through Street Level Address Validation Service, additional attribute C<quality> will be set to either 0 or 1. 1 means that the address is valid.

=head1 METHODS

In addition to accessor methods documented above, following convenience methods are provided.

=over 4

=item is_match()

=head1 METHODS

In addition to accessor methods documented above, following convenience methods are provided.

=over 4

=item validate()

=item validate(\%args)

Validates the address by submitting itself to US Street Level Address Validation service. For this method to work Net::UPS singleton needs to be created first.

=back

=head1 AUTHOR AND LICENSING

For support and licensing information refer to L<Net::UPS|Net::UPS/"AUTHOR">

=cut
