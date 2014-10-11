#!plackup
use strict;
use warnings;

use Plack::Request;
use Imager;

use constant MORSE => {
	"A"=>".-",
	"B"=>"-...",
	"C"=>"-.-.",
	"D"=>"-..",
	"E"=>".",
	"F"=>"..-.",
	"G"=>"--.",
	"H"=>"....",
	"I"=>"..",
	"J"=>".---",
	"K"=>"-.-",
	"L"=>".-..",
	"M"=>"--",
	"N"=>"-.",
	"O"=>"---",
	"P"=>".--.",
	"Q"=>"--.-",
	"R"=>".-.",
	"S"=>"...",
	"T"=>"-",
	"U"=>"..-",
	"V"=>"...-",
	"W"=>".--",
	"X"=>"-..-",
	"Y"=>"-.--",
	"Z"=>"--..",
	"0"=>"-----",
	"1"=>".----",
	"2"=>"..---",
	"3"=>"...--",
	"4"=>"....-",
	"5"=>".....",
	"6"=>"-....",
	"7"=>"--...",
	"8"=>"---..",
	"9"=>"----.",
	"."=>".-.-.-",
	","=>"--..--",
	"?"=>"..--..",
	"'"=>".----.",
	"!"=>"-.-.--",
	"/"=>"-..-.",
	"("=>"-.--.",
	")"=>"-.--.-",
	"&"=>".-...",
	":"=>"---...",
	";"=>"-.-.-.",
	"="=>"-...-", 
	"+"=>".-.-.", 
	"-"=>"-....-",
	"_"=>"..--.-",
	"\""=>".-..-.",
	"\$"=>"...-..-",
	"@"=>".--.-.",
	"\n" => ".-.-", 
	"\x01" => "-.-.-", 
	"\x04" => "...-.-" 
};

my $on = Imager->new(
	xsize => 16,
	ysize => 16,
	channels => 1,
);
$on->box(filled => 1, color => '#000000');

my $off = Imager->new(
	xsize => 16,
	ysize => 16,
	channels => 1,
);
$off->box(filled => 1, color => '#ffffff');

sub {
	my $req = Plack::Request->new(shift);

	my $text = $req->param('text') || $req->param('TEXT') || 'APPEND TEXT QUERY PARAMETER';
	$text = substr($text, 0, 100);

	my $wpm = $req->param('wpm') || 10;

	my $images = [];
	for my $c (split //, $text) {
		if ($c eq ' ') {
			push @$images, ($off) x 4;
		} else {
			my $code = MORSE->{uc $c};
			next unless $code;
			for my $s (split //, $code) {
				if ($s eq '.') {
					push @$images, $on, $off;
				} elsif ($s eq '-') {
					push @$images, $on, $on, $on, $off;
				}
			}
			push @$images, ($off) x 2;
		}
	}
	push @$images, ($off) x 7;

	Imager->write_multi(
		{
			data => \my $data,
			type => 'gif',
			gif_delay => 120 / $wpm,
			gif_loop => 0, # inifinite
		},
		@$images,
	) or die Imager->errstr;

	[
		200,
		[ 'Content-Type' => 'image/gif' ],
		[ $data ],
	];
}
