#!/bin/bash
./node_modules/webpack/bin/webpack.js
sbt 'run com.benpence.blog.server.BlogServerMain'
