use strict;
use utf8;
use Test::More tests => 61;

BEGIN
{
    use_ok("Data::Visitor::Encode");
}

do 't/checkfunc.pl';

my $nihongo = "日本語";
my $aiueo   = "あいうえお";
my %source;
my %visited;

my $ev = 'Data::Visitor::Encode';

my $check_utf8_on = make_check_closure(sub { Encode::is_utf8($_[0]) }, "utf8");
my $check_utf8_off = make_check_closure(sub { ! Encode::is_utf8($_[0]) }, "NOT utf8");

# Hash
%source = (
    $nihongo => $aiueo, 
    nested_hashref   => { $nihongo => $aiueo },
    nested_arrayref  => [ $nihongo, $aiueo ],
    nested_scalarref => \$nihongo,
);
my $visited = $ev->utf8_off(\%source);
$check_utf8_off->($visited);

$visited = $ev->utf8_on($visited);
$check_utf8_on->($visited);

# List
my @source = (
    $nihongo, $aiueo,
    { $nihongo => $aiueo },
    [ $nihongo, $aiueo ],
    \$nihongo
);
$visited = $ev->utf8_off(\@source);
$check_utf8_off->($visited);

$visited = $ev->utf8_on($visited);
$check_utf8_on->($visited);

# Scalar (Ref)
my $source = \$nihongo;
$visited = $ev->utf8_off($source);
$check_utf8_off->($visited);

$visited = $ev->utf8_on($visited);
$check_utf8_on->($visited);

# Scalar
$source = $nihongo;
$visited = $ev->utf8_off($source);
$check_utf8_off->($visited);

$visited = $ev->utf8_on($visited);
$check_utf8_on->($visited);

# Object
my $class = 'DVETestObject';
$visited = $ev->utf8_off(bless \%source, $class);
$check_utf8_off->($visited);
isa_ok($visited, $class);

$visited = $ev->utf8_on($visited);
$check_utf8_on->($visited);
isa_ok($visited, $class);

1;
