package MediaWords::Util::Annotator::CLIFF;

use strict;
use warnings;

use Modern::Perl "2015";
use MediaWords::CommonLibs;

{

    package MediaWords::Util::Annotator::CLIFF::Proxy;

    use strict;
    use warnings;

    use Modern::Perl "2015";
    use MediaWords::CommonLibs;    # set PYTHONPATH too

    import_python_module( __PACKAGE__, 'mediawords.annotator.cliff' );

    1;
}

sub new
{
    my ( $class ) = @_;

    my $self = {};
    bless $self, $class;

    $self->{ _annotator } = MediaWords::Util::Annotator::CLIFF::Proxy::CLIFFAnnotator->new();

    return $self;
}

sub story_is_annotated($$$)
{
    my ( $self, $db, $stories_id ) = @_;

    return $self->{ _annotator }->story_is_annotated( $db, $stories_id );
}

sub annotate_and_store_for_story($$$)
{
    my ( $self, $db, $stories_id ) = @_;

    return $self->{ _annotator }->annotate_and_store_for_story( $db, $stories_id );
}

sub fetch_annotation_for_story($$$)
{
    my ( $self, $db, $stories_id ) = @_;

    return $self->{ _annotator }->fetch_annotation_for_story( $db, $stories_id );
}

sub update_tags_for_story($$$)
{
    my ( $self, $db, $stories_id ) = @_;

    return $self->{ _annotator }->update_tags_for_story( $db, $stories_id );
}

1;
