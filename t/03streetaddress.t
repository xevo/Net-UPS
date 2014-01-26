
use strict;
use Test::More;
use File::Spec;
use Net::UPS;

my $upsrc = File::Spec->catfile($ENV{HOME}, ".upsrc");
my $ups = undef;
unless (defined($ups = Net::UPS->new($upsrc)) ) {
    plan(skip_all=>Net::UPS->errstr);
    exit(0);
}

plan(tests=>10);

ok($ups);

use_ok("Net::UPS");
use_ok("Net::UPS::StreetAddress");



my $address = Net::UPS::StreetAddress->new();
ok( $address->can("name")
    && $address->can("building_name") 
    && $address->can("address")
    && $address->can("address2") 
    && $address->can("address3")  
    && $address->can("city") 
    && $address->can("postal_code") 
    && $address->can("postal_code_extended") 
    && $address->can("state") 
    && $address->can("country_code")
    && $address->can("is_residential")
    && $address->can("is_commercial")
    && $address->can("quality")
);

$address->name("John Doe");
$address->building_name("Pearl Hotel");
$address->address("233 W 49th St");
$address->city("New York");
$address->postal_code("10019");
$address->postal_code_extended("");
$address->state("NY");
$address->country_code("US");

ok($address->city           eq "New York"   );
ok($address->postal_code    eq "10019"      );
ok($address->state          eq "NY"         );
ok($address->country_code   eq "US"         );

my $response_address = $address->validate();
ok( $response_address && ref($response_address) && (ref $response_address eq "Net::UPS::StreetAddress") );
ok( $response_address->is_match );
