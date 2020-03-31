default['ess-elastic-ls-prd']['rpm_location'] = 'https://artifacts.elastic.co/downloads/logstash/logstash-6.4.3.rpm'
default['ess-elastic-ls-prd']['elasticsearch_url'] = 'elasticsearch.internal.elastic.aws.autodesk.com'
default['ess-elastic-ls-prd']['elasticsearch_port'] = 9200
default['ess-elastic-ls-prd']['elasticsearch_username'] = 'logstash'
default['ess-elastic-ls-prd']['elasticsearch_password'] = 'changeme'
default['ess-elastic-ls-prd']['hec-token']['aum'] = 'token'
default['ess-elastic-ls-prd']['hec-token']['shotgunpci'] = 'token'
default['ess-elastic-ls-prd']['queue_max_bytes'] = 10737418240 # 10GB
# default['ess-elastic-ls-prd']['efs_mount'] = 'fs-3eaad677.efs.us-east-1.amazonaws.com:/'
default['ess-elastic-ls-prd']['logstash_url'] = 'logstash.elastic.aws.autodesk.com'
default['ess-elastic-ls-prd']['logstash_port'] = 5000
override['ess-elastic-metricbeat-prd']['application'] = 'logstash'
override['ess-elastic-filebeat-prd']['inputs'] = [
  {
    "index": 'elastic',
    "group": 'elasticlog',
    "paths": [
      '/var/log/logstash/logstash-plain.log',
    ],
    "multiline_pattern": "'^\\[\\d\\d\\d\\d'",
    "multiline_negate": true,
    "multiline_match": 'after',
    "fields": [
      {
        "field": 'application',
        "value": 'logstash',
      },
      {
        "field": 'environment',
        "value": 'prd',
      },
      {
        "field": 'type',
        "value": 'pipeline',
      },
    ],
  },
  {
    "index": 'os',
    "group": 'elasticlog',
    "paths": [
      '/var/log/messages',
      '/var/log/secure',
    ],
    "fields": [
      {
        "field": 'application',
        "value": 'logstash',
      },
      {
        "field": 'environment',
        "value": 'prd',
      },
      {
        "field": 'type',
        "value": 'pipeline',
      },
    ],
  },
]
