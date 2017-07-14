#!/usr/bin/perl
use strict;
# for a sequence of production rules of form 'A ==> B C ...' delimited by '//'
# Output a sequence in CNF, e.g. A ==> A A ... // A ==> B // A ==> C // ...

sub trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };

for (<ARGV>)
{
    chomp;
    my @rules = split(/\/\//);
    my @out;
    my @stack = ();
    my $last_rhs = '';
    foreach my $rule (@rules){
	# if the LHS = the last output RHS (or no previous output RHS):
	#     if length 1:
	#        output the rule
	#     else: 
	#        output the multirule, output the first rule, add rest to stack
	# else: 
        #     pop from the stack, add it to the output
	#     check the new last output RHS
	#     then do above
	$rule = trim($rule);
	my @split_rule = split(/ ==> /, $rule);
	my $lhs = $split_rule[0];
	my @rhs = split(/ /, $split_rule[1]);
        while (not ($lhs eq $last_rhs or $last_rhs eq '') and scalar @stack > 0){
	    my $from_stack = pop @stack;
	    my @split_from_stack = split(/ ==> /, $from_stack);
	    my @split_rhs = split(/ /, $split_from_stack[1]);
	    $last_rhs = $split_rhs[0];
	    if ($last_rhs ne ''){
		push(@out, $from_stack);
	    }
	}

	if (scalar @rhs eq 1){
	    $last_rhs = $rhs[0];
	    push(@out, $rule);
	}

	else{
	    my $multi_rhs = "$lhs " x (scalar @rhs - 1);
	    my $multi_rule = "$lhs ==> $multi_rhs$lhs";
	    if ($lhs ne ''){
		push(@out, $multi_rule);
	    }
	    my @to_push = reverse @rhs;
	    $last_rhs = pop(@to_push);
	    if ($lhs ne $last_rhs and $last_rhs ne ''){
		push(@out, "$lhs ==> $last_rhs");
	    }
	    foreach my $single_rhs (@to_push){
		if ($lhs ne $single_rhs and $last_rhs ne ''){
		    push(@stack, "$lhs ==> $single_rhs");
		}
		else{
		    push(@stack, '');
		}
	    }
	}
    }
    my $out_line = join(" // ", @out);
    
    print "$out_line\n";
}
