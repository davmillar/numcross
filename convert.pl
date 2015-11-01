#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
use JSON;

my $filename = 'src/example.num';
my $mode = 0;

my @puzzlegrid = ();
my %puzzledimensions = (
  "width" => 11,
  "height" => 11
);

my %numberclues;
$numberclues{"across"} = ();
$numberclues{"down"} = ();

my %letterclues;
$letterclues{"across"} = ();
$letterclues{"down"} = ();


my %ipuz_data = (
  "version" => "http://ipuz.org/v1",
  "kind" => ["http://ipuz.org/crossword#1"],
  "copyright" => "David Millar",
  "author" => "David Millar",
  "publisher" => "The Griddle",
  "title" => "Numcross",
  "intro" => "Solve the puzzle using the clues provided.",
  "empty" => "0",
  "charset" => "0123456789",
  "dimensions" => %puzzledimensions,
);

open(my $fh, '<:encoding(UTF-8)', $filename)
  or die "Could not open file '$filename' $!";

while (my $row = <$fh>) {
  chomp $row;
  if ($row eq '---') {
    $mode++;
  } elsif ($mode eq 0) {
    push @puzzlegrid, $row;
  } elsif ($mode eq 1) {
    my ($letterclue, $numberclue) = parseClue($row);
    push @{$letterclues{"across"}}, $letterclue;
    push @{$numberclues{"across"}}, $numberclue;
  } elsif ($mode eq 2) {
    my ($letterclue, $numberclue) = parseClue($row);
    push @{$letterclues{"down"}}, $letterclue;
    push @{$numberclues{"down"}}, $numberclue;
  } else {
    print "$row\n";
  }
}

print Dumper(@puzzlegrid);
print Dumper(%letterclues);
print Dumper(%numberclues);

my $ipuz_json = encode_json \%ipuz_data;
print $ipuz_json;

sub parseClue {
  my $cluetext = $_[0];
  my $letterclue = $_[0];
  my $numberclue = $_[0];
  while ($cluetext =~ m/({([A-Z]+)\-([AD])})/g) {
    my $clueentry = $2;
    my $cluedirletter = $3;
    my $cluedirection = ($cluedirletter eq 'A') ? 'Across' : 'Down';
    my $clueentrynum = (26 * (length($clueentry) - 1)) + (ord(substr($clueentry, 0, 1)) - 64);
    $letterclue =~ s/({${clueentry}\-${cluedirletter}})/${clueentry} ${cluedirection}/i;
    $numberclue =~ s/({${clueentry}\-${cluedirletter}})/${clueentrynum}-${cluedirection}/i;
  }
  return ($letterclue, $numberclue)
}