#!/usr/bin/perl
use strict;

package Node;
use Scalar::Util qw(weaken);

my $delim = ' // ';
 
sub new {
    my $class = shift;
    my $self = {@_};
    $self->{parent} = undef unless $self->{parent};
    $self->{children} = [];
    bless($self, $class);
    weaken $self->{parent};
    return $self;
}

sub add {
    my ($self, $child_label) = @_;
    push $self->{children}, Node->new(label=>$child_label, parent=>$self);
    return $self->{children}[-1];
}


sub disp{
    my $self = shift;
    if (@{$self->{children}}) {
	print "$self->{label} ==> ";
	for (@{$self->{children}}){
	    print "$_->{label} ";
	}
	print $delim;
    }
    for (@{$self->{children}}){
	$_->disp();
    }
}

sub make_node{
    my ($node, $tok) = @_;
    my $current_node;
    if ($node){
	$current_node = $node->add($tok);
    }
    else{
	$current_node = Node->new(label=>$tok);
    }
    return $current_node;
}
my $current_node;
my $root;
my $count = 0;
my $last_time = time;
while(<ARGV>)
{
    chomp;
    my @toks = split(/ /);
    for (my $i = 0; $i <= $#toks; $i++){
	if ($toks[$i] eq '('){
	    if (not defined $root) {
		$root = make_node("", 'ROOT');
		$current_node = $root;
	    }
	    else {
		$current_node =  make_node($current_node, $toks[$i + 1]);
	    }
	}
	elsif ($toks[$i] eq ')'){
	    $current_node = $current_node->{parent};
	}
	elsif (not ($toks[$i + 1] eq ')' or $toks[$i + 1] eq '(')){
	    make_node($current_node, $toks[$i + 1]);
	}
    }
    $root->disp();
    print "\n";
    $count += 1;
    if (($count % 10000) == 0){
	my $diff = time - $last_time;
	print STDERR "line $count, approx. 10k time $diff\n";
	$last_time = time;
    }
}
