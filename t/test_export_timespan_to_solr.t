#!/usr/bin/env perl

# test that the timespan field gets exported to solr

use strict;
use warnings;

BEGIN
{
    use FindBin;
    use lib "$FindBin::Bin/../../lib";

}

use Modern::Perl '2015';
use MediaWords::CommonLibs;

use Test::More;

use MediaWords::Solr::Dump;
use MediaWords::TM;
use MediaWords::TM::Snapshot;
use MediaWords::Test::Solr;
use MediaWords::Test::Supervisor;

my $_test_supervisor_called;

sub test_timespan_export
{
    my ( $db ) = @_;

    my $media = MediaWords::Test::DB::create_test_story_stack(
        $db,
        {
            medium_1 => { feed_1 => [ map { "story_$_" } ( 1 .. 10 ) ] },
            medium_2 => { feed_2 => [ map { "story_$_" } ( 11 .. 20 ) ] },
            medium_3 => { feed_3 => [ map { "story_$_" } ( 21 .. 30 ) ] },
        }
    );
    MediaWords::Test::DB::add_content_to_test_story_stack( $db, $media );

    my $topic = MediaWords::Test::DB::create_test_topic( $db, 'foo' );

    MediaWords::Test::Solr::setup_test_index( $db );

    my $num_solr_sentences = MediaWords::Solr::get_num_found( $db, { q => '*:*' } );
    ok( $num_solr_sentences > 0, "total number of solr sentences is greater than 0" );

    my $topic_media_id = $media->{ medium_1 }->{ media_id };

    my $num_topic_medium_sentences = MediaWords::Solr::get_num_found( $db, { q => "media_id:$topic_media_id" } );
    ok( $num_topic_medium_sentences > 0, "number of topic medium sentences is greater than 0" );

    $db->query( <<SQL, $topic->{ topics_id }, $topic_media_id );
insert into topic_stories ( topics_id, stories_id )
    select \$1, stories_id from stories where media_id = \$2
SQL

    MediaWords::TM::Snapshot::snapshot_topic( $db, $topic->{ topics_id } );

    $num_solr_sentences = MediaWords::Solr::get_num_found( $db, { q => 'timespans_id:1' } );
    is( $num_solr_sentences, 0, "number of solr sentences before snapshot import" );

    my ( $num_solr_exported_stories ) = $db->query( "select count(*) from solr_import_extra_stories" )->flat;
    my $num_topic_medium_stories = scalar( values( %{ $media->{ medium_1 }->{ feeds }->{ feed_1 }->{ stories } } ) );
    is( $num_solr_exported_stories, $num_topic_medium_stories, "number of stories added to solr export queue" );

    my $timespan = MediaWords::TM::get_latest_overall_timespan( $db, $topic->{ topics_id } );

    MediaWords::Solr::Dump::generate_and_import_data( 1 );

    my $num_topic_sentences = MediaWords::Solr::get_num_found( $db, { q => "timespans_id:$timespan->{ timespans_id }" } );
    is( $num_topic_sentences, $num_topic_medium_sentences, "topic sentences after snapshot" );

    # TODO:
    # * test focus creation
    # * fix and test pseudo queries
    # * fix pseudo queries to always chunk?

}

sub main
{
    MediaWords::Test::Supervisor::test_with_supervisor( \&test_timespan_export, [ qw/solr_standalone/ ] );

    done_testing();
}

main();
