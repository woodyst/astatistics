use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Catalyst::Test', 'Astatistics' }
BEGIN { use_ok 'Astatistics::Controller::Results' }

ok( request('/results')->is_success, 'Request should succeed' );
done_testing();
