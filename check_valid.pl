#!/usr/bin/perl
use strict;
# for a sequence of production rules of form 'A ==> B C ...' delimited by '//'
# check that the parse is valid
# (e.g. non-terminals follow on from each other in pre-order)

my @special = qw( N -RRB -LRB -RCB -LCB US$ C$ A$ HK$ M$ S$ );
my %lookup = map { $_ => undef } @special;

sub is_terminal {
    if ((scalar @_ <= 1) and 
	((lc $_[0] eq $_[0]) or (exists $lookup{$_[0]}))){
	return 1;
    }
    return 0;
}

while (<ARGV>)
{
    chomp;
    my @rules = split(/ \/\/ /);
    my @stack;
    my $valid = 1;
    my $first = 1;
    foreach my $rule (@rules){
	my @rule = split(/ ==> /, $rule);
	if (($first and ($rule[0] eq 'ROOT')) or
	    ($rule[0] eq $stack[-1])){
	    if (not $first){
		pop @stack;
	    }
	    # okay if LHS is ROOT 
	    # or equal to what you get from popping the stack
	    my @rhs = split(/ /, $rule[1]);
	    if (not is_terminal(@rhs)) {
		# push rhs onto stack if contains non-terminals
		push (@stack, reverse @rhs);
	    }
	    if ($first){
		$first = 0;
	    }
	}
	elsif ($rule[0] eq 'UNK'){
	    # once we output UNK we can't track the stack
	    last;
	}
	else{
	    my $out = join(' // ', @rules);
	    print "$rule[0] $stack[-1]\n";
	    print "$out\n";
	    print "INVALID\n";
	    last;
	}
    }
}
