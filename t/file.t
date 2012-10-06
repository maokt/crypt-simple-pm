#!/usr/bin/perl

=head1 NAME

file.t - test

=head1 DESCRIPTION

Check we can use the 'file' option.

=cut

use strict;
use warnings;

use Test::More tests => 6;

use File::Temp 'tempfile';

sub make_tempfile {
	my ($data) = @_;
	my ($io, $name) = tempfile();
	print {$io} $data;
	close $io;
	return $name;
}

my $foo = make_tempfile("abcdefgh");
my $bar = make_tempfile("zyxwvuts");
my $baz = make_tempfile("abcdefgh");
END { unlink $foo, $bar, $baz }

require_ok('Crypt::Simple');

{
	package Foo;
	Crypt::Simple->import(file => $foo);
}

{
	package Bar;
	Crypt::Simple->import(file => $bar);
}

{
	package Baz;
	Crypt::Simple->import(file => $baz);
}

my $plaintext = "hello world";
my $footext = Foo::encrypt($plaintext);
my $bartext = Bar::encrypt($plaintext);
my $baztext = Baz::encrypt($plaintext);

isnt $footext, $bartext, "Foo and Bar are different";
is $footext, $baztext, "Foo and Baz are the same";
is Foo::decrypt($footext), $plaintext, "Foo encryption";
is Bar::decrypt($bartext), $plaintext, "Bar encryption";
is Baz::decrypt($baztext), $plaintext, "Baz encryption";
