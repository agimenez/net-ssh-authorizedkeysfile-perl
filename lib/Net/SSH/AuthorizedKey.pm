###########################################
package Net::SSH::AuthorizedKey;
###########################################
use strict;
use warnings;
use Log::Log4perl qw(:easy);

###########################################
sub parse {
###########################################
    my($class, $string) = @_;

    my @subclasses = qw(
        Net::SSH::AuthorizedKey::SSH1
        Net::SSH::AuthorizedKey::SSH2
    );

    for my $subclass ( @subclasses ) {
        my $pk = $subclass->parse( $string );
        if($pk) {
            DEBUG "Successfully parsed $subclass key";
            return $pk;
        }
    }

    return undef;
}

1;

__END__

=head1 NAME

Net::SSH::AuthorizedKey - Virtual Base Class for SSH Public Keys

=head1 SYNOPSIS

    use Net::SSH::AuthorizedKey;

    my $key = Net::SSH::AuthorizedKey->parse( $line );

    if(defined $key) {
          # ssh-1 or ssh-2
        print "Key parsed, type is ", $key->type(), "\n";
    } else {
        die "Cannot parse key (", $key->error(), ")";
    }

=head1 DESCRIPTION

Net::SSH::AuthorizedKey is a virtual base class for ssh public keys. 
Real implementations of it are Net::SSH::AuthorizedKey::SSH1 and
Net::SSH::AuthorizedKey::SSH2. 

The only way to using it directly is by calling its parse() method, and handing
it an authorized_keys string (aka a line from an authorized_keys file). If it
recognizes either a ssh-1 or a ssh-2 type key, it will return a
Net::SSH::AuthorizedKey::SSH1 or a Net::SSH::AuthorizedKey::SSH2 object.
See their manual pages for instructions on how to use them.

=head1 NOTES FOR SUBCLASS DEVELOPERS

If you're just using Net::SSH::AuthorizedKey to parse keys, the
following section doesn't concern you. It's only relevant if you add 
new subclasses to this package, on top of what's already provided.

Net::SSH::AuthorizedKey is a (semi-)virtual base class implements 
options handling for its SSH1 and SSH2 subclasses.

SSH key lines can contain options that carry values (like command="ls") and
binary options that are either set or unset (like "no_agent_forwarding").  To
distinguish the two, and to provide a set of allowed option names, the subclass
has to implement the method option_type(), which takes an option name, and
returns

=over 4

=item *

undef if the option is not supported

=item *

"s" if the option is a "string" option that carries a value

=item *

1 if the option is a binary option

=back

The subclasses Net::SSH::AuthorizedKey::SSH1 and Net::SSH::AuthorizedKey::SSH2
are doing this already.

=head1 LEGALESE

Copyright 2005-2009 by Mike Schilli, all rights reserved.
This program is free software, you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 AUTHOR

2005, Mike Schilli <m@perlmeister.com>
