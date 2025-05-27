#!/usr/bin/env bash

ITERATIONS=${1:-10}
total=0

for ((i=1; i<=ITERATIONS; i++)); do
    cycles=$(zig build run 2>&1 | grep "Cycles" | sed 's/Cycles \([0-9]*\)/\1/')
    total=$((total + cycles))
done

echo "Average: $((total / ITERATIONS)) cycles"
