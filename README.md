Net-UPS
=======

This is a fork of the CPAN Net::UPS module at:
http://search.cpan.org/~sherzodr/Net-UPS-0.04/

I added support for the street level address validation API.

Street level validation usage:
    
    my $address = Net::UPS::StreetAddress->new();
    $address->name("John Doe");
    $address->address("123 Test Street");
    $address->address2("APT A);
    $address->city("New York");
    $address->state("NY");
    $address->postal_code("10007");
    $address->country_code("US");
    
    # the new Net::UPS::StreetAddress object must be passed in, not a Net::UPS::Address object 
    my $address = $ups->validate_street_address($address);
    if ( $ups->errstr )
    {
        if ($address)
        {
            # if an address was returned but an errstr is set it means that this is a "candidate" address
            # candidate addresses are not safe to ship to, but it will point you in the right direction
            # so that you can manually correct the address
            print "Possible address (not safe to ship to):\n";
            print $address->building_name . "\n" if $address->building_name;
            print $address->address . "\n";
            print $address->address2 . "\n" if $address->address2;
            print $address->address3 . "\n" if $address->address3;
            print $address->city . ", " . $address->state . " " . $address->postal_code . "-" . $address->postal_code_extended . "\n";
            print $address->country_code . "\n";
        }
        die $ups->errstr;
    }
    # the API might have made some changes to the address we gave it
    # this is the sanitized address that UPS says is safe to ship to
    print "Sanitized address:\n";
    print $address->building_name . "\n" if $address->building_name;
    print $address->address . "\n";
    print $address->address2 . "\n" if $address->address2;
    print $address->address3 . "\n" if $address->address3;
    print $address->city . ", " . $address->state . " " . $address->postal_code . "-" . $address->postal_code_extended . "\n";
    print $address->country_code . "\n";

