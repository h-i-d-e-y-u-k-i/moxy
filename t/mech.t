use strict;
use warnings;
use utf8;
use Test::Requires 'Test::WWW::Mechanize::PSGI';
use Test::More;
use Moxy;
use FindBin;
use File::Spec::Functions qw/catfile/;

binmode Test::More->builder->$_, ":utf8" for qw/output failure_output todo_output/;

my $moxy = Moxy->new(
    {
        global => {
            assets_path => catfile( $FindBin::Bin, '..', 'assets' ),
            'log' => {
                level => 'info',
            },
            session => {
                store => {
                    module => 'Test',
                    config => {},
                },
            }
        },
        plugins => [
            { module => 'UserAgentSwitcher' },
        ],
    }
);
my $app = $moxy->to_app();

# -------------------------------------------------------------------------

my $mech = Test::WWW::Mechanize::PSGI->new(app => $app);
$mech->get('/');
is $mech->res->code(), 401;
$mech->credentials('oh', 'my god');
$mech->get_ok('/');
$mech->get_ok('/http://wassr.jp/');
$mech->content_contains('お気軽');

done_testing;
