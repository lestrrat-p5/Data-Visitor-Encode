use strict;
use utf8;
use Test::More tests => 61;
use Encode;

BEGIN
{
    use_ok("Data::Visitor::Encode");
}

do 't/checkfunc.pl';

my $nihongo = "日本語";
my $aiueo   = "あいうえお";
my %source;
my %visited;

%source = ($nihongo => $aiueo);

my $ev = Data::Visitor::Encode->new();

my $check_flag_off = make_check_closure(
    sub {
        return ! Encode::is_utf8($_[0]);
    }, "utf8 flag off"
);
my $check_flag_on = make_check_closure(
    sub {
        return Encode::is_utf8($_[0]);
    }, "utf8 flag on"
);

# Hash
%source = (
    $nihongo => $aiueo, 
    nested_hashref   => { $nihongo => $aiueo },
    nested_arrayref  => [ $nihongo, $aiueo ],
    nested_scalarref => \$nihongo,
);
my $visited = $ev->decode_utf8(\%source);
$check_flag_on->($visited);

$visited = $ev->encode_utf8($visited);
$check_flag_off->($visited);

# List
my @source = (
    $nihongo, $aiueo,
    { $nihongo => $aiueo },
    [ $nihongo, $aiueo ],
    \$nihongo
);
$visited = $ev->decode_utf8(\@source);
$check_flag_on->($visited);

$visited = $ev->encode_utf8($visited);
$check_flag_off->($visited);

# Scalar (Ref)
my $source = \$nihongo;
$visited = $ev->decode_utf8($source);
$check_flag_on->($visited);

$visited = $ev->encode_utf8($visited);
$check_flag_off->($visited);

# Scalar
$source = $nihongo;
$visited = $ev->decode_utf8($source);
$check_flag_on->($visited);

$visited = $ev->encode_utf8($visited);
$check_flag_off->($visited);

# Object
my $class = 'DVETestObject';
$visited = $ev->decode_utf8(bless \%source, $class);
$check_flag_on->($visited);
isa_ok($visited, $class);

$visited = $ev->encode_utf8($visited);
$check_flag_off->($visited);
isa_ok($visited, $class);

1;
