#!/usr/bin/env perl
use warnings;
use strict;

use XML::Simple qw(:strict);
use Data::Dumper;
use File::Copy;

my $feed_path = "http://www.nasa.gov/rss/lg_image_of_the_day.rss";

my $tmp_image = '/tmp/bckground.tmp';
my $image     = '/tmp/bckground.jpg';

my $data = `wget -O - $feed_path 2> /dev/null`;

if(($? >> 8) != 0) {
	if(-t STDOUT) {
		print "Error fetching page with wget\n";
	}
	exit 1;
}

my $ref = XMLin($data, ForceArray => [], KeyAttr => {});

if(!$ref) {
	if(-t STDOUT) {
		print "Error parsing XML\n";
	}
	exit 1;
}

my $link = $ref->{channel}->{item}->{enclosure}->{url};
my $title = $ref->{channel}->{item}->{title};
my $description = $ref->{channel}->{item}->{description};

print Dumper $ref;

if(!$link || !$title || !$description) {
	if(-t STDOUT) {
		print "No data in hashref\n"
	}
	exit 1;
}

`wget -O $tmp_image $link 2> /dev/null`;

if(($? >> 8) != 0) {
	if(-t STDOUT) {
		print "Error fetching image\n";
	}
	if(-e $tmp_image) {
		unlink($tmp_image);
	}
	exit 1;
}

move($tmp_image, $image);

`awsetbg -a $image`;