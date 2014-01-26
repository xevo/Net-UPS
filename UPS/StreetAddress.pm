package Net::UPS::StreetAddress;
use strict;
use Carp;
use XML::Simple;
use Class::Struct;

struct(
    quality              => '$',
    name                 => '$',
    building_name        => '$',
    address              => '$',
    address2             => '$',
    address3             => '$',
    city                 => '$',
    postal_code          => '$',
    postal_code_extended => '$',
    state                => '$',
    country_code         => '$',
    is_residential       => '$',
    is_commercial        => '$',
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
    if ( defined $self->building_name ) {
           $data{AddressKeyFormat}->{BuildingName} = $self->building_name();
    }
    
    $data{AddressKeyFormat}->{AddressLine} = [];
    if ( defined $self->address ) {
        push(@{ $data{AddressKeyFormat}->{AddressLine} }, $self->address());
    }
    if ( defined $self->address2 ) {
        push(@{ $data{AddressKeyFormat}->{AddressLine} }, $self->address2());
    }
    if ( defined $self->address3 ) {
        push(@{ $data{AddressKeyFormat}->{AddressLine} }, $self->address3());
    }
    
    if ( defined $self->city ) {
        $data{AddressKeyFormat}->{PoliticalDivision2} = $self->city();
    }
    if ( defined $self->state ) {
        $data{AddressKeyFormat}->{PoliticalDivision1} = $self->state_province_code;
    }
    
    if ( defined $self->postal_code_extended ) {
        $data{AddressKeyFormat}->{PostcodeExtendedLow} = $self->postal_code_extended;
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
    $address->address2("APT B");
    $address->city("New York");
    $address->state("NY");
    $address->postal_code("10007");
    $address->country_code("US");

=head1 DESCRIPTION

Net::UPS::StreetAddress is a class representing a shipping address.
Valid address attributes are:

=over 4

=item name

Name of business, company or person.

=item building_name

Name of building.

=item address, address2, address3

Address line (street number, street name and street type) used for street level information.

=item city

City or Town.

=item state

State/Province.

=item postal_code

Low-end Postal Code.

=item postal_code_extended

Low-end extended postal code in a range. Example in quotes: Postal Code 30076-'1234'.

=item country_code

A 2-letter country code.

=back

=head1 METHODS

In addition to accessor methods documented above,
the following convenience methods are provided after the address is run through the Street Level Address Validation service:

=over 4

=item is_match()

=item is_residential()

=item is_commercial()

=back

=head1 METHODS

The following convenience methods are also provided:

=over 4

=item validate()

=item validate(\%args)

Validates the address by submitting itself to US Street Level Address Validation service. For this method to work Net::UPS singleton needs to be created first.

=back

=head1 AUTHOR AND LICENSING

For support and licensing information refer to L<Net::UPS|Net::UPS/"AUTHOR">

=cut
