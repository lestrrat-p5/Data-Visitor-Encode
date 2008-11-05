# $Id$

package Test::Data::Visitor::Encode;
use strict;
use warnings;
use Data::Visitor::Callback;
use Encode ();
use Test::More;

#BEGIN {
#    my $builder = Test::More->builder;
#    foreach my $output qw(output failure_output todo_output) {
#        binmode($builder->$output, ':utf8');
#    }
#}

sub import {
    my $caller = caller(1);

    foreach my $method qw(decode_utf8_ok encode_utf8_ok) {
        no strict 'refs';
        *{"${caller}::${method}"} = \&{$method};
    }
}

sub encode_utf8_ok {
    my ($data, $title) = @_;

    my $dve = Data::Visitor::Encode->new();
    $data = $dve->encode_utf8($data);

    Data::Visitor::Callback->new(
        ignore_return_values => 1,
        object => "visit_ref",
        plain_value => sub {
            my $caller;
            my $i = 1;
            do {
                $caller = caller($i++);
            } while ($caller =~ /Data::Visitor/);

            local $Test::Builder::Level = $Test::Builder::Level + $i;
            ok(!Encode::is_utf8($_[1], 1), "value $_[1] is not utf8 for '$title'");
        }
    )->visit($data);
}

sub decode_utf8_ok {
    my ($data, $title) = @_;

    my $dve = Data::Visitor::Encode->new();
    $data = $dve->decode_utf8($data);

    Data::Visitor::Callback->new(
        ignore_return_values => 1,
        object => "visit_ref",
        plain_value => sub {
            my $caller;
            my $i = 1;
            do {
                $caller = caller($i++);
            } while ($caller =~ /Data::Visitor/);

            local $Test::Builder::Level = $Test::Builder::Level + $i;
            ok(Encode::is_utf8($_[1], 1), Encode::encode_utf8("value $_[1] is utf8 for '$title'"));
        }
    )->visit($data);
}

1;
