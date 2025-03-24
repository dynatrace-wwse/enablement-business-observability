#!/bin/bash

# lab guide
cd lab-guide
node bin/generator.js
nohup node bin/server.js > /dev/null 2>&1 &