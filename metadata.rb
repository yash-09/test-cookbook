name             'ess-elastic-ls-prd'
maintainer       'Autodesk, Inc'
maintainer_email 'jacob.gorney@autodesk.com'
license          'All rights reserved'
description      'Installs/Configures Logstash Pipeline'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.2.0'
supports         'amazon'
chef_version '>= 12.14' if respond_to?(:chef_version)
issues_url 'https://git.autodesk.com/ESS/elastic-ls-prd/issues'
source_url 'https://git.autodesk.com/ESS/elastic-ls-prd'
# depends 'ess-elastic-selinux-disable'
# depends 'ess-elastic-filebeat-prd'
# depends 'ess-elastic-metricbeat-prd'
