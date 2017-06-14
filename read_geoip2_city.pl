#!/usr/bin/perl
use SimpleR::Reshape;
use Net::CIDR qw/cidr2range/;
use Socket qw/inet_aton/;

my %loc;
#geoname_id,locale_code,continent_code,continent_name,country_iso_code,country_name,subdivision_1_iso_code,subdivision_1_name,subdivision_2_iso_code,subdivision_2_name,city_name,metro_code,time_zone
#1392,zh-CN,AS,"亚洲",IR,"伊朗伊斯兰共和国",21,,,,,,Asia/Tehran
my $loc_f='GeoIP2-City-Locations-zh-CN.csv';
read_table($loc_f, 
    #write_file => "$f.tidy",
    skip_head => 1, 
    return_arrayref=>0, 
    conv_sub => sub {
        my ($r) = @_;
        s/"//g for @$r;
        # 4, 6, 5, 7 => country_code, area_code, country, area
        $loc{$r->[0]} = $r;
        return;
    },
);

my $f = 'GeoIP2-City-Blocks-IPv4.csv';
#network,geoname_id,registered_country_geoname_id,represented_country_geoname_id,is_anonymous_proxy,is_satellite_areaiderostal_code,latitude,longitude
#1.0.0.0/24,2077456,2077456,,0,0,,-27,133.0000
read_table($f, 
    write_file => "$f.tidy",
    skip_head => 1, 
    return_arrayref=>0, 
    conv_sub => sub {
        my ($r) = @_;
        s/"//g for @$r;
        my @inf = cidr2range("$r->[0]");
        my ( $s_ip, $e_ip ) = $inf[0] =~ /(.+?)-(.+)/;
        my ( $s_inet, $e_inet ) = map { unpack( 'N', inet_aton($_) ) } ( $s_ip, $e_ip );
        my $x = $loc{$r->[1]};
        return [ $s_inet, $e_inet, $x->[4] || '', $x->[6] || '', $x->[5] || '', $x->[7] || '' ];
    },
);
