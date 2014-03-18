##Etymolog

Exploratory tool for word etymologies. Still in the works. Uses
[Neo4j](http://www.neo4j.org/) on the backend, Node.js in the middle and
[D3.js](http://d3js.org/) in the front.

`git clone https://github.com/nsonnad/etymolog`

`cd etymolog`

Run `make` to collect data, parse and toss it into a Neo4j database, as well as
download all Node dependencies. That could take a while.

When it's done, all the database stuff is ready to go. You may now get running
with the front-end by doing:

1. `cd app`
2. `gulp`
3. Point your browser to http://localhost:3000


