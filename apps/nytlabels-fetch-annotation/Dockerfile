#
# NYTLabels fetch annotation worker
#

FROM dockermediacloud/nytlabels-base:latest

# Copy sources
COPY src/ /opt/mediacloud/src/nytlabels-fetch-annotation/
ENV PERL5LIB="/opt/mediacloud/src/nytlabels-fetch-annotation/perl:${PERL5LIB}" \
    PYTHONPATH="/opt/mediacloud/src/nytlabels-fetch-annotation/python:${PYTHONPATH}"

# Copy worker script
COPY bin /opt/mediacloud/bin

USER mediacloud

CMD ["nytlabels_fetch_annotation_worker.py"]
