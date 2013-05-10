package Logger;

use strict;

our $verbose;

sub new {
    my ($class, $v) = @_;
    $verbose = $v;

    my $self = {
        'indent' => 0,
    };
    bless $self, $class;
    return $self;
}

sub message {
    my ($self, $m) = @_;
    print "  " x $self->{indent} . $m . "\n" if $verbose;
}

sub indent {
    my $self = shift;
    $self->{indent}++;
}
sub undent {
    my $self = shift;
    $self->{indent}--;
}

1;

