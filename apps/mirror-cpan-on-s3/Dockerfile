#
# Script to mirror CPAN to S3 for easier Perl dependencies installing
#

FROM dockermediacloud/perl-python-base:latest

# Install dependencies
RUN \
    pip3.7 install s4cmd && \
    cpm install --global --no-prebuilt CPAN::Mini && \
    rm -rf /root/.perl-cpm/ && \
    true

COPY bin/mirror-cpan-on-s3.sh /

USER mediacloud

CMD ["/mirror-cpan-on-s3.sh"]
