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

my $check_euc_jp = make_check_closure(
    sub {
        eval { Encode::decode('euc-jp', $_[0], Encode::FB_CROAK()) };
        return !$@;
    }, "euc-jp"
);
my $check_utf8 = make_check_closure(
    sub {
        eval { Encode::encode('utf-8', $_[0], Encode::FB_CROAK()) };
        return !$@
    }, "utf8"
);

# Hash
%source = (
    $nihongo => $aiueo, 
    nested_hashref   => { $nihongo => $aiueo },
    nested_arrayref  => [ $nihongo, $aiueo ],
    nested_scalarref => \$nihongo,
);
my $visited = $ev->encode('euc-jp', \%source);
$check_euc_jp->($visited);

$visited = $ev->decode('euc-jp', $visited);
$check_utf8->($visited);

# List
my @source = (
    $nihongo, $aiueo,
    { $nihongo => $aiueo },
    [ $nihongo, $aiueo ],
    \$nihongo
);
$visited = $ev->encode('euc-jp', \@source);
$check_euc_jp->($visited);

$visited = $ev->decode('euc-jp', $visited);
$check_utf8->($visited);

# Scalar (Ref)
my $source = \$nihongo;
$visited = $ev->encode('euc-jp', $source);
$check_euc_jp->($visited);

$visited = $ev->decode('euc-jp', $visited);
$check_utf8->($visited);

# Scalar
$source = $nihongo;
$visited = $ev->encode('euc-jp', $source);
$check_euc_jp->($visited);

$visited = $ev->decode('euc-jp', $visited);
$check_utf8->($visited);

# Object
my $class = 'DVETestObject';
$visited = $ev->encode('euc-jp', bless \%source, $class);
$check_euc_jp->($visited);
isa_ok($visited, $class);

$visited = $ev->decode('euc-jp', $visited);
$check_utf8->($visited);
isa_ok($visited, $class);

1;
