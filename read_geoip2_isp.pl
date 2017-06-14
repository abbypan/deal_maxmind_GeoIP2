#!/usr/bin/perl
use SimpleR::Reshape;
use Net::CIDR qw/cidr2range/;
use Socket qw/inet_aton/;

#1.0.0.0/24,Google,Google,15169,"Google Inc."
#my @src_head = qw/cidr isp org as as_org/;

my $f='GeoIP2-ISP-Blocks-IPv4.csv';

open my $fh, '<', $f;
open my $fhw, '>', "$f.tidy";
<$fh>;
while(<$fh>){
    chomp;
    my @d = m#("[^"]+"|[^,]+)#g;
    s/"//g for @d;
    s/,/ /g for @d;
    my @inf = cidr2range("$d[0]");
    my ( $s_ip, $e_ip ) = $inf[0] =~ /(.+?)-(.+)/;
    my ( $s_inet, $e_inet ) = map { unpack( 'N', inet_aton($_) ) } ( $s_ip, $e_ip );
    print $fhw join(",", $s_inet, $e_inet, $d[1], $d[3] ),"\n";
}
close $fhw;
close $fh;

#read_table($f, 
    #write_file => "$f.tidy",
    #skip_head => 1, 
    #return_arrayref=>0, 
    #conv_sub => sub {
        #my ($r) = @_;
        #s/"//g for @$r;
        #my @inf = cidr2range("$r->[0]");
        #my ( $s_ip, $e_ip ) = $inf[0] =~ /(.+?)-(.+)/;
        #my ( $s_inet, $e_inet ) = map { unpack( 'N', inet_aton($_) ) } ( $s_ip, $e_ip );
        #return [ $s_inet, $e_inet, $r->[1], $r->[3] ];
    #},
#);


