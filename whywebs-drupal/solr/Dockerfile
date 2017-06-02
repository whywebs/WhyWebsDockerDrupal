
FROM solr:5.5.4-alpine

# We just add a core with the search_api_solr config to the
# base image here.
RUN mkdir -p /opt/solr/server/solr/whywebs-drupal/data
ADD conf/ /opt/solr/server/solr/whywebs-drupal/conf/
ADD core.properties /opt/solr/server/solr/whywebs-drupal/core.properties
