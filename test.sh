#!/bin/bash

echo "Testing website on DEV..."

curl -f http://localhost:8081 || exit 1

echo "DEV website is reachable"
