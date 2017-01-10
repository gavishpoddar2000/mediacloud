package MediaWords::Model::DBIS;

# custom MediaWords::DB::Handler based model for mediawords

use strict;
use warnings;

use Modern::Perl "2015";
use MediaWords::CommonLibs;

use base qw(Catalyst::Model);

use MediaWords::DB;
use MediaWords::DB::Handler;

sub new
{
    my $self = shift->SUPER::new( @_ );

    my @info = @{ $self->{ connect_info } || [] };

    return $self;
}

# hand out a database connection.  reuse the last connection unless the request has changed
# since the last call.
sub dbis
{
    my ( $self, $request ) = @_;

    my $db = $self->{ dbis };

    my $prev_req_id = $self->{ prev_req_id } || '';
    my $req_id = scalar( $request );

    return $db if ( $db && ( $req_id eq $prev_req_id ) );

    $self->{ prev_req_id } = $req_id;

    # we put an eval and print the error here b/c the web auth dies silently on a database error
    eval {
        # ->connect is smart enough to reuse current connection
        $db = MediaWords::DB::Handler->connect( MediaWords::DB::connect_info );

        $self->{ dbis } = $db;
    };
    if ( $@ )
    {
        LOGDIE "Database error: $@";
    }

    return $db;
}

1;
