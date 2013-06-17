package Logger;


use strict;
use warnings;

sub new {
    my ($class, $v) = @_;
    $v = 0 if !defined $v;

    my $self = {
        'indent' => 0,
        'verbose' => $v,

        'total-tests' => 0,
        'failures' => 0,
        'current-test' => '',
        'current-unit' => undef,

        'test-names' => {},
    };
    bless $self, $class;
    return $self;
}

#-----------------------------------------------------------------------------
# This changes the current test.
# It also increments the total-tests counter, so it should only be called after
# filterMatch, to make sure this is a real test on a real sample or samplegroup.

sub setCurrentTest {
    # $unit is the "unit under test", a sample or samplegroup
    my ($self, $test, $unit) = @_;

    # Keep track of the total number of different tests we've seen, as a hash of
    # test names
    $self->{'test-names'}{$test} = 1;

    # Increment the total-tests counter, and record this test number
    my $testNum = $self->{'total-tests'}++;

    # Create a new hash attached to the unit-under-test, that will record this
    # test and its pass/fail status
    my $testRecord = { 'name' => $test, 'failed' => 0 };
    push @{$unit->{tests}}, $testRecord;

    # Set some state variables
    $self->{'current-test'} = $test;
    $self->{'current-unit'} = $unit;
    $self->{'current-test-record'} = $testRecord;

    my $smsg;
    if ($unit->{isa} eq 'samplegroup') {
        $smsg = 'samplegroup ' . $unit->{dtd};
    }
    else {
        $smsg = 'sample ' . $unit->{name};
    }
    $self->message("TEST #$testNum: $test: " . $smsg);
}

#------------------------------------------------------------------------
sub setVerbose {
    my ($self, $v) = @_;
    $self->{verbose} = $v;
}

#------------------------------------------------------------------------
# These two methods output messages, and only differ in the "severity level".
# These should be overridden by other types of loggers.

sub message {
    my ($self, $m) = @_;
    print "  " x $self->{indent} . $m . "\n" if $self->{verbose};
    my $unit = $self->{'current-unit'};
    push @{$unit->{msgs}}, $m;
}

sub error {
    my ($self, $m) = @_;
    print "  " x $self->{indent} . $m . "\n";
}



#------------------------------------------------------------------------
# This method records a test failure, and outputs an "error" message.

sub failed {
    my ($self, $msg) = @_;

    # Output the error-type message
    $self->error("FAILED:  $msg");

    # Increment the total-failure counter (if we haven't before)
    my $testRecord = $self->{'current-test-record'};
    if (!$testRecord->{failed}) {
        $self->{failures}++;
    }

    # Record this failure status in the current unit-under-test
    my $unit = $self->{'current-unit'};
    $unit->{failed} = 1;
    $testRecord->{failed} = 1;

    # If this is a sample, then it also counts as a failure for the samplegroup
    if ($unit->{isa} eq 'sample') {
        $unit->{sg}{failed} = 1;
    }
}

#------------------------------------------------------------------------
# These are specific to this standard-out logger.

sub _indent {
    my $self = shift;
    $self->{indent}++;
}
sub _undent {
    my $self = shift;
    $self->{indent}--;
}

1;

