#!/bin/bash
# Run As: root
# Update internal configuration in accordance to GitHub.
#
# Application: Logstash
# Node Type:   Ingestor
# Data Type:   N/A
#
# Configuration Repo: https://git.autodesk.com/EIO-PaaS/Elastic-Config
# Author: Jacob Gorney <jacob.gorney@autodesk.com>
# Slack: @gorneyj
#
APPLICATION="logstash"
NODE_TYPE="pipeline"

# Clean
rm -rf /tmp/elastic-config.zip
rm -rf /tmp/elastic-config
rm -rf /tmp/elastic-logstash.zip
rm -rf /tmp/elastic-logstash

# Fetch the latest configuration payload
curl https://jenkins.elastic.aws.autodesk.com/files/elastic-config.zip -k -o /tmp/elastic-config.zip --silent
curl https://jenkins.elastic.aws.autodesk.com/files/elastic-logstash.zip -k -o /tmp/elastic-logstash.zip --silent

# Unzip the latest configuration payload
unzip -qq /tmp/elastic-config.zip -d /tmp/elastic-config
rm -rf /tmp/elastic-config.zip
unzip -qq /tmp/elastic-logstash.zip -d /tmp/elastic-logstash
rm -rf /tmp/elastic-logstash.zip

# Make sure the directory exists first
if [ -d "/tmp/elastic-config" ]; then
  # Elasticsearch Configuration Update
  # Will update elasticsearch.yml (Requires service reboot - needs to be done manually),
  # And role_mapping.yml which does not require an update.
  if [ "$APPLICATION" == "elasticsearch" ]; then
    echo "Checking elasticsearch"
    # Calculate hashes to determine if we need to update the core config files
    ROLE_MAPPING_YML="/etc/elasticsearch/x-pack/role_mapping.yml"
    ELASTICSEARCH_YML="/etc/elasticsearch/elasticsearch.yml"
    ROLE_MAPPING_YML_SHA=$(sha256sum /etc/elasticsearch/x-pack/role_mapping.yml | awk '{print $1}')
    ZIP_ROLE_MAPPING_YML="/tmp/elastic-config/elasticsearch/role_mapping.yml"
    ZIP_ROLE_MAPPING_YML_SHA=$(sha256sum /tmp/elastic-config/elasticsearch/role_mapping.yml | awk '{print $1}')
    ELASTICSEARCH_YML_SHA=$(sha256sum /etc/elasticsearch/elasticsearch.yml | awk '{print $1}')
    # Master Node
    if [ "$NODE_TYPE" == "master" ]; then
      ZIP_ELASTICSEARCH_YML="/tmp/elastic-config/elasticsearch/master/elasticsearch.yml"
      ZIP_ELASTICSEARCH_YML_SHA=$(sha256sum /tmp/elastic-config/elasticsearch/master/elasticsearch.yml | awk '{print $1}')
      # Perform magic
      if [ "$ZIP_ELASTICSEARCH_YML_SHA" != "$ELASTICSEARCH_YML_SHA" ]; then
        echo "Updating elasticsearch master node config"
        rm -rf $ELASTICSEARCH_YML
        /bin/cp -rf $ZIP_ELASTICSEARCH_YML $ELASTICSEARCH_YML
        chown elasticsearch:elasticsearch $ELASTICSEARCH_YML
        chmod 0755 $ELASTICSEARCH_YML
      fi
    fi
    # Client Node
    if [ "$NODE_TYPE" == "client" ]; then
      ZIP_ELASTICSEARCH_YML="/tmp/elastic-config/elasticsearch/client/elasticsearch.yml"
      ZIP_ELASTICSEARCH_YML_SHA=$(sha256sum /tmp/elastic-config/elasticsearch/client/elasticsearch.yml | awk '{print $1}')
      # Perform magic
      if [ "$ZIP_ELASTICSEARCH_YML_SHA" != "$ELASTICSEARCH_YML_SHA" ]; then
        echo "Updating elasticsearch client node config"
        /bin/cp -rf $ZIP_ELASTICSEARCH_YML $ELASTICSEARCH_YML
        chown elasticsearch:elasticsearch $ELASTICSEARCH_YML
        chmod 0755 $ELASTICSEARCH_YML
      fi
    fi
    # Data Node - hot
    if [ "$NODE_TYPE" = "data-hot" ]; then
      ZIP_ELASTICSEARCH_YML="/tmp/elastic-config/elasticsearch/data/hot/elasticsearch.yml"
      ZIP_ELASTICSEARCH_YML_SHA=$(sha256sum /tmp/elastic-config/elasticsearch/data/hot/elasticsearch.yml | awk '{print $1}')
      # Perform magic
      if [ "$ZIP_ELASTICSEARCH_YML_SHA" != "$ELASTICSEARCH_YML_SHA" ]; then
        echo "Updating elasticsearch hot data node config"
        /bin/cp -rf $ZIP_ELASTICSEARCH_YML $ELASTICSEARCH_YML
        chown elasticsearch:elasticsearch $ELASTICSEARCH_YML
        chmod 0755 $ELASTICSEARCH_YML
      fi
    fi
    # Data Node - warm
    if [ "$NODE_TYPE" == "data-warm" ]; then
      ZIP_ELASTICSEARCH_YML="/tmp/elastic-config/elasticsearch/data/warm/elasticsearch.yml"
      ZIP_ELASTICSEARCH_YML_SHA=$(sha256sum /tmp/elastic-config/elasticsearch/data/warm/elasticsearch.yml | awk '{print $1}')
      # Perform magic
      if [ "$ZIP_ELASTICSEARCH_YML_SHA" != "$ELASTICSEARCH_YML_SHA" ]; then
        echo "Updating elasticsearch warm data node config"
        /bin/cp -rf $ZIP_ELASTICSEARCH_YML $ELASTICSEARCH_YML
        chown elasticsearch:elasticsearch $ELASTICSEARCH_YML
        chmod 0755 $ELASTICSEARCH_YML
      fi
    fi
    # Update role_mapping.yml; doesn't matter what type of node it is
    if [ "$ZIP_ROLE_MAPPING_YML_SHA" != "$ROLE_MAPPING_YML_SHA" ]; then
      echo "Updating elasticsearch role_mapping.yml"
      /bin/cp -rf $ZIP_ROLE_MAPPING_YML $ROLE_MAPPING_YML
      chown elasticsearch:elasticsearch $ROLE_MAPPING_YML
      chmod 0755 $ROLE_MAPPING_YML
    fi
  fi

  # Logstash Configuration Update
  # Will update Logstash filters on nodes
  # Logstash filters are on auto-reload so all we need to do is replace them
  if [ "$APPLICATION" == "logstash" ]; then
    echo "Checking logstash"
    # Ingestor filters
    if [ "$NODE_TYPE" == "ingestor" ]; then
      echo "Updating logstash ingestor filters"
      ZIP_LOGSTASH_FILTERS="/tmp/elastic-config/logstash/ingestor/filters"
      LOGSTASH_FILTERS="/etc/logstash/conf.d"
      /bin/cp -rf $ZIP_LOGSTASH_FILTERS/*filter*.conf $LOGSTASH_FILTERS/
      chown -R logstash:logstash $LOGSTASH_FILTERS/*filter*.conf
      chmod -R 0400 $LOGSTASH_FILTERS/*filter*.conf
    fi
    # Shipper filters
    if [ "$NODE_TYPE" == "shipper" ]; then
      echo "Updating logstash shipper filters"
      ZIP_LOGSTASH_FILTERS="/tmp/elastic-config/logstash/shipper/filters"
      LOGSTASH_FILTERS="/etc/logstash/conf.d"
      /bin/cp -rf $ZIP_LOGSTASH_FILTERS/*filter*.conf $LOGSTASH_FILTERS/
      chown -R logstash:logstash $LOGSTASH_FILTERS/*filter*.conf
      chmod -R 0400 $LOGSTASH_FILTERS/*filter*.conf
    fi
    # Pipeline filters
    if [ "$NODE_TYPE" == "pipeline" ]; then
      echo "Updating logstash pipeline filters"
      ZIP_LOGSTASH_FILTERS="/tmp/elastic-config/logstash/filters"
      LOGSTASH_FILTERS="/etc/logstash/conf.d"
      /bin/cp -rf $ZIP_LOGSTASH_FILTERS/*filter*.conf $LOGSTASH_FILTERS/
      chown -R logstash:logstash $LOGSTASH_FILTERS/*filter*.conf
      chmod -R 0400 $LOGSTASH_FILTERS/*filter*.conf
    fi
  fi

  # Remove the files from /tmp
  rm -rf /tmp/elastic-config
fi

if [ -d "/tmp/elastic-logstash" ]; then
  # Logstash Configuration Update
  # Will update Logstash filters on nodes
  # Logstash filters are on auto-reload so all we need to do is replace them
  if [ "$APPLICATION" == "logstash" ]; then
    echo "Checking logstash"
    # Pipeline filters
    if [ "$NODE_TYPE" == "pipeline" ]; then
      echo "Updating logstash pipeline filters"
      ZIP_LOGSTASH_FILTERS="/tmp/elastic-logstash/filters"
      LOGSTASH_FILTERS="/etc/logstash/conf.d"
      /bin/cp -rf $ZIP_LOGSTASH_FILTERS/*filter*.conf $LOGSTASH_FILTERS/
      chown -R logstash:logstash $LOGSTASH_FILTERS/*filter*.conf
      chmod -R 0400 $LOGSTASH_FILTERS/*filter*.conf
    fi
  fi

  # Remove the files from /tmp
  rm -rf /tmp/elastic-logstash
fi

echo "Done"
# Done
