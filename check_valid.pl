#!/usr/bin/perl
use strict;
# for a sequence of production rules of form 'A ==> B C ...' delimited by '//'
# check that the parse is valid
# (e.g. non-terminals follow on from each other in pre-order)

my %nts;
my @special = qw( N -RRB -LRB -RCB -LCB -LRB- -RRB- -LCB- -LCB-);
my %lookup = map { $_ => undef } @special;

sub is_terminal {
    if (scalar @_ == 2){
	if (not exists $nts{$_[1]}){
	    return 1;
	}
	elsif (((lc $_[1] eq $_[1]) or (exists $lookup{$_[1]})) and ($_[1] eq $_[0])){
	    return 1;
       }
    }
    return 0;
}

my $ln = 0;
my @lines = <ARGV>;
for (@lines){
    chomp;
    my @rules = split(/ \/\/ /);
    foreach my $rule(@rules){
	my @rule = split(/ ==> /, $rule);
	$nts{$rule[0]} = 1;
    }
}

for (@lines)
{
    chomp;
    my @rules = split(/ \/\/ /);
    my @stack;
    my $valid = 1;
    my $first = 1;
    my @out = ();

    foreach my $rule (@rules){
	my @rule = split(/ ==> /, $rule);
	if (($first and ($rule[0] eq 'ROOT')) or
	    ($rule[0] eq $stack[-1])){
	    if (not $first){
		pop @stack;
	    }
	    push (@out, $rule);
	    # okay if LHS is ROOT 
	    # or equal to what you get from popping the stack
	    my @rhs = split(/ /, $rule[1]);
	    if (not is_terminal(@rule[0], @rhs)) {
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
	    push (@out, ($rule, '<- ERROR'));
	    my $out = join(' // ', @out);
	    print "INVALID line $ln: Rule LHS is $rule[0], top of stack is $stack[-1], $out\n";
	    last;
	}
    }
    $ln = $ln + 1;
}
