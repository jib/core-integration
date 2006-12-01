#!perl
use strict;
use Getopt::Std;

my $opts = {};
getopts('ushv', $opts );

die usage() if $opts->{h};

my $file    = shift or die "Need file\n". usage();
my $outfile = shift || '';
my $mode    = (stat($file))[2] & 07777;

open my $fh, $file or die "Could not open input file $file: $!";
my $str  = do { local $/; <$fh> };

### unpack?
my $outstr;
if( $opts->{u} ) {
    $outfile ||= $file . '.packed'; 
    $outstr  = unpack 'u', $str;   
} else {
    if( !$outfile ) {
        $outfile = $file;
        $outfile =~ s/\.packed$//;
    } 
    $outstr = pack 'u', $str;
}    

if( $opts->{'s'} ) {
    print STDOUT $outstr;
} else {
    open my $outfh, ">$outfile" or die "Could not open $file for writing: $!";
    print $outfh $outstr;
    close $outfh;
    
    chmod $mode, $outfile;
}

sub usage {
    return qq[
Usage: $0 [-v] [-s] source [output]
       $0 [-v] [-s] -u source [output]
       $0 -h
       
    uuencodes a file, either to a target file or STDOUT.
    If no output file is provided, it outputs to FILE.packed
    
Options:
    -v  Run verbosely
    -s  Output to STDOUT rather than file
    -h  Display this help message
    -u  Unpack rather than pack

    \n]
}    
