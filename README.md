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


###TODO

####Back-end
* Deployment to heroku
  * make sure gulp build process is working
  * [gulp buildpack](https://github.com/appstack/heroku-buildpack-nodejs-gulp)
  * import existing db
* Limit number of nodes returned from Cypher
* Change url based on selected word

####Front-end
* ~~Highlight node of currently selected word~~
* Tooltips on nodes
* Allow clicking on node (or in the tooltip) to load its graph
* Links to wiktionary pages
* Lots of aesthetic stuff
