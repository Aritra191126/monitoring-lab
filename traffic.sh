#!/bin/bash
for i in {1..50}; do
  curl -s localhost:8000/fast > /dev/null
  curl -s localhost:8000/slow > /dev/null
  curl -s localhost:8000/flaky > /dev/null
  sleep 0.1
done