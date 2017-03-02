package MediaWords::Controller::Api::V2::Topics::Timespans;
use Modern::Perl "2015";
use MediaWords::CommonLibs;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Moose;
use namespace::autoclean;

BEGIN { extends 'MediaWords::Controller::Api::V2::MC_Controller_REST' }

__PACKAGE__->config( action => { list => { Does => [ qw( ~TopicsReadAuthenticated ~Throttled ~Logged ) ] }, } );

sub apibase : Chained('/') : PathPart('api/v2/topics') : CaptureArgs(1)
{
    my ( $self, $c, $topics_id ) = @_;
    $c->stash->{ topics_id } = $topics_id;
}

sub timespans : Chained('apibase') : PathPart('timespans') : CaptureArgs(0)
{

}

sub list : Chained('timespans') : Args(0) : ActionClass('MC_REST')
{

}

sub list_GET
{
    my ( $self, $c ) = @_;

    my $db = $c->dbis;

    my $topics_id = $c->stash->{ topics_id };

    my $snapshots_id = $c->req->params->{ snapshots_id };
    my $foci_id      = $c->req->params->{ foci_id };
    my $timespans_id = $c->req->params->{ timespans_id };

    my $snapshot = $db->require_by_id( 'snapshots', $snapshots_id ) if ( $snapshots_id );
    my $focus    = $db->require_by_id( 'foci',      $foci_id )      if ( $foci_id );
    my $timespan = $db->require_by_id( 'timespans', $timespans_id ) if ( $timespans_id );

    if ( !$snapshot && !$timespan )
    {
        $snapshot = $db->query( <<SQL, $topics_id )->hash;
select * from snapshots where topics_id = \$1 and state = 'completed' order by snapshot_date desc limit 1
SQL
        die( "Unable to find valid spanshot" ) unless ( $snapshot );
    }

    my $snapshot_clause = $snapshot ? "and snapshots_id = $snapshot->{ snapshots_id }" : "";
    my $focus_clause    = $focus    ? "and foci_id = $focus->{ foci_id }"              : "and foci_id is null";
    my $timespan_clause = $timespan ? "and timespans_id = $timespan->{ timespans_id }" : "";

    my $timespans = $db->query( <<SQL )->hashes;
select
            timespans_id,
            period,
            start_date,
            end_date,
            story_count,
            story_link_count,
            medium_count,
            medium_link_count,
            model_r2_mean,
            model_r2_stddev,
            model_num_media,
            foci_id,
            snapshots_id
        from timespans t
        where
            true
            $snapshot_clause
            $focus_clause
            $timespan_clause
        order by period, start_date, end_date
SQL

    $self->status_ok( $c, entity => { timespans => $timespans } );
}

1;
