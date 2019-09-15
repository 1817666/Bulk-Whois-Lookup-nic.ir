#!/usr/bin/perl
use strict;
use warnings;
use LWP::UserAgent;

my ($file, $fh, $domain, $ua, $response, $string, $filehandler, $url, $email, $expire);
$file = 'list.txt';
open($fh, $file) or die "Could not open file '$file' $!";
while ($domain = <$fh>) {
	chomp $domain;
	$url = "http://whois.nic.ir/?name=" . $domain;
	$ua = LWP::UserAgent->new;
	$response = $ua->get( $url );
	$string = $response->content;
	if ($string =~ '\<pre\>\n\<\/pre\>') {
		open(my $filehandler, '>>', 'result.txt');
		print $filehandler $domain . ", Blocked Request!\n";
		close $filehandler;
	}
	elsif ($string =~ 'Bad\s+query') {
		open(my $filehandler, '>>', 'result.txt');
		print $filehandler $domain . ", Bad Query!\n";
		close $filehandler;
	}
	elsif ($string =~ 'no\s+entries\s+found') {
		open(my $filehandler, '>>', 'result.txt');
		print $filehandler $domain . ", FREE.\n";
		close $filehandler;
	}
	elsif ($string =~ 'This\s+domain\s+is\s+not\s+available\s+for\s+registration') {
		open(my $filehandler, '>>', 'result.txt');
		print $filehandler $domain . ", This domain is not available for registration.\n";
		close $filehandler;
	}
	elsif ($string =~ 'This\s+domain\s+is\s+only\s+available\s+for\s+registration\s+under\s+certain\s+conditions') {
		open(my $filehandler, '>>', 'result.txt');
		print $filehandler $domain . ", This domain is only available for registration under certain conditions.\n";
		close $filehandler;
	}
	else {
		$email = $& if $string =~ '[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+';
		$expire = $& if $string =~ '(?<=expire-date:\t)[0-9]{4}-[0-9]{2}-[0-9]{2}';
		open(my $filehandler, '>>', 'result.txt');
		print $filehandler $domain . ", Email: " . $email . ", Expire Date: " . $expire . "\n";
		close $filehandler;
	}
	sleep(10)
}
