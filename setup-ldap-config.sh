cat << EOF > /usr/local/etc/elksig/data.ldif
dn: ou=users,dc=example,dc=com
objectclass: organizationalunit
ou: users
dn: uid=admin,ou=users,dc=example,dc=com
objectclass: inetOrgPerson
objectclass: person
gn: administrator
sn: admin
cn: administrateur admin
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
  echo "Wrote out /usr/local/etc/sensu-docker/data.ldif"
ldapadd -h localhost -p 389 -c -x -D cn=admin,dc=example,dc=com -W -f /usr/local/etc/sensu-docker/data.ldif
echo "toor"
