# Install a local Neo4j instance
NEO4J_VERSION=neo4j-community-2.0.0
curl http://dist.neo4j.org/$NEO4J_VERSION-unix.tar.gz --O $NEO4J_VERSION-unix.tar.gz

tar -zxvf $NEO4J_VERSION-unix.tar.gz
rm $NEO4J_VERSION-unix.tar.gz
ln -s $NEO4J_VERSION/bin/neo4j neo4j
