#!/bin/bash
mkdir /usr/local/etc/elksig
cat << EOF > /usr/local/etc/elksig/data.ldif
# The root node (dc=example,dc=com) is automatically created by the Docker container instantiation (nickstenning/slap$

# All the users
dn: ou=users,dc=example,dc=com
objectclass: organizationalunit
ou: users

dn: uid=admin,ou=users,dc=example,dc=com
objectclass: inetOrgPerson
objectclass: person
gn: administrator
sn: Admin
cn: administrator admin
uid: admin
userPassword: changeme


# All the groups
dn: ou=groups,dc=example,dc=com
objectclass: organizationalunit
ou: groups

dn: cn=monitoring,ou=groups,dc=example,dc=com
objectclass: groupofnames
cn: monitoring
description: All the monitoring users
member: uid=admin,ou=users,dc=example,dc=com
EOF
  echo "Wrote out /usr/local/etc/elksig/data.ldif"
ldapadd -h localhost -p 389 -c -x -D cn=admin,dc=example,dc=com -W -f /usr/local/etc/elksig/data.ldif

