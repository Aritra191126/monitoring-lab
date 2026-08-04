for i in {1..10}; do
    curl -s localhost:8000/fast > /dev/null
    curl -s localhost:8000/slow > /dev/null
    curl -s localhost:8000/flaky > /dev/null
done    