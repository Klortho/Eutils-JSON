package Logger;

use strict;
use warnings;

sub new {
    my ($class, $v) = @_;

    my $self = {
        'indent' => 0,
        'verbose' => $v,
    };
    bless $self, $class;
    return $self;
}

sub message {
    my ($self, $m) = @_;
    print "  " x $self->{indent} . $m . "\n" if $self->{verbose};
}

sub error {
    my ($self, $m) = @_;
    print "  " x $self->{indent} . $m . "\n";
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

