default['aar']['required-packages'] = [ 'unzip',
                                        'curl',
                                        'apache2',
                                        'mysql-server',
                                        'libapache2-mod-wsgi',
                                        'python-mysqldb',
                                        'python-pip' ]

# Usernames and passwords; should refactor to databag or vault
default['aar']['web-user'] = 'www-data'
default['aar']['web-group'] = 'www-data'
default['aar']['mysql-host'] = 'localhost'
default['aar']['mysql-root-user'] = 'root'
default['aar']['mysql-root-password'] = '' # Using default MySQL root password; should be changed and refactored
default['aar']['app-db'] = 'AARdb'
default['aar']['app-db-user'] = 'aarapp'
default['aar']['app-db-password'] = 'Also5uper5ecret'
default['aar']['app-db-secret'] = 'Really5uper5ecret'
