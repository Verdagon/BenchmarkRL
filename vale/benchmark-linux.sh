#!/bin/bash

MAP_SIZE=500

# Compile into VAST, since it will be the same for every region.
python3 ../valec.py build ../vstl/list.vale ../vstl/hashmap.vale ../vstl/hashset.vale src/*.vale --gen-heap --region-override unsafe-fast

# First, compile the various binaries with all the regions.
python3 ../valec.py build build.vast --gen-heap --region-override unsafe-fast -o benchmarkRL-unsafefast
python3 ../valec.py build build.vast --gen-heap --region-override naive-rc -o benchmarkRL-naiverc
python3 ../valec.py build build.vast --gen-heap --region-override resilient-v3 -o benchmarkRL-resilientv3
# python3 ../valec.py build build.vast --gen-heap --region-override assist -o benchmarkRL-assist
# python3 ../valec.py build build.vast --gen-heap --region-override resilient-v1 -o benchmarkRL-resilientv1
# python3 ../valec.py build build.vast --gen-heap --region-override resilient-v1 --elide-checks-for-known-live -o benchmarkRL-resilientv1ecfkl
# python3 ../valec.py build build.vast --gen-heap --region-override resilient-v3 --elide-checks-for-known-live -o benchmarkRL-resilientv3ecfkl
# Note: other valid regions are resilient-v0, resilient-v1, resilient-v2, and resilient-limit

# Now, begin the benchmarking!
# 1. Copy this output into an editor like sublime
# 2. Sort it to group the times by mode
# 3. Take out the best and worst number for each (outliers)
# 4. Average the remaining ones for each

echo "unsafe-fast: $(/usr/bin/time -f "%e" ./benchmarkRL-unsafefast $MAP_SIZE 2>&1)"
echo "naive-rc: $(/usr/bin/time -f "%e" ./benchmarkRL-naiverc $MAP_SIZE 2>&1)"
# echo "assist: $(/usr/bin/time -f "%e" ./benchmarkRL-assist $MAP_SIZE 2>&1)"
# echo "resilient-v1: $(/usr/bin/time -f "%e" ./benchmarkRL-resilientv1 $MAP_SIZE 2>&1)"
# echo "resilient-v1-ecfkl: $(/usr/bin/time -f "%e" ./benchmarkRL-resilientv1ecfkl $MAP_SIZE 2>&1)"
echo "resilient-v3: $(/usr/bin/time -f "%e" ./benchmarkRL-resilientv3 $MAP_SIZE 2>&1)"
# echo "resilient-v3-ecfkl: $(/usr/bin/time -f "%e" ./benchmarkRL-resilientv3ecfkl $MAP_SIZE 2>&1)"

echo "unsafe-fast: $(/usr/bin/time -f "%e" ./benchmarkRL-unsafefast $MAP_SIZE 2>&1)"
echo "naive-rc: $(/usr/bin/time -f "%e" ./benchmarkRL-naiverc $MAP_SIZE 2>&1)"
# echo "assist: $(/usr/bin/time -f "%e" ./benchmarkRL-assist $MAP_SIZE 2>&1)"
# echo "resilient-v1: $(/usr/bin/time -f "%e" ./benchmarkRL-resilientv1 $MAP_SIZE 2>&1)"
# echo "resilient-v1-ecfkl: $(/usr/bin/time -f "%e" ./benchmarkRL-resilientv1ecfkl $MAP_SIZE 2>&1)"
echo "resilient-v3: $(/usr/bin/time -f "%e" ./benchmarkRL-resilientv3 $MAP_SIZE 2>&1)"
# echo "resilient-v3-ecfkl: $(/usr/bin/time -f "%e" ./benchmarkRL-resilientv3ecfkl $MAP_SIZE 2>&1)"

echo "unsafe-fast: $(/usr/bin/time -f "%e" ./benchmarkRL-unsafefast $MAP_SIZE 2>&1)"
echo "naive-rc: $(/usr/bin/time -f "%e" ./benchmarkRL-naiverc $MAP_SIZE 2>&1)"
# echo "assist: $(/usr/bin/time -f "%e" ./benchmarkRL-assist $MAP_SIZE 2>&1)"
# echo "resilient-v1: $(/usr/bin/time -f "%e" ./benchmarkRL-resilientv1 $MAP_SIZE 2>&1)"
# echo "resilient-v1-ecfkl: $(/usr/bin/time -f "%e" ./benchmarkRL-resilientv1ecfkl $MAP_SIZE 2>&1)"
echo "resilient-v3: $(/usr/bin/time -f "%e" ./benchmarkRL-resilientv3 $MAP_SIZE 2>&1)"
# echo "resilient-v3-ecfkl: $(/usr/bin/time -f "%e" ./benchmarkRL-resilientv3ecfkl $MAP_SIZE 2>&1)"

echo "unsafe-fast: $(/usr/bin/time -f "%e" ./benchmarkRL-unsafefast $MAP_SIZE 2>&1)"
echo "naive-rc: $(/usr/bin/time -f "%e" ./benchmarkRL-naiverc $MAP_SIZE 2>&1)"
# echo "assist: $(/usr/bin/time -f "%e" ./benchmarkRL-assist $MAP_SIZE 2>&1)"
# echo "resilient-v1: $(/usr/bin/time -f "%e" ./benchmarkRL-resilientv1 $MAP_SIZE 2>&1)"
# echo "resilient-v1-ecfkl: $(/usr/bin/time -f "%e" ./benchmarkRL-resilientv1ecfkl $MAP_SIZE 2>&1)"
echo "resilient-v3: $(/usr/bin/time -f "%e" ./benchmarkRL-resilientv3 $MAP_SIZE 2>&1)"
# echo "resilient-v3-ecfkl: $(/usr/bin/time -f "%e" ./benchmarkRL-resilientv3ecfkl $MAP_SIZE 2>&1)"

echo "unsafe-fast: $(/usr/bin/time -f "%e" ./benchmarkRL-unsafefast $MAP_SIZE 2>&1)"
echo "naive-rc: $(/usr/bin/time -f "%e" ./benchmarkRL-naiverc $MAP_SIZE 2>&1)"
# echo "assist: $(/usr/bin/time -f "%e" ./benchmarkRL-assist $MAP_SIZE 2>&1)"
# echo "resilient-v1: $(/usr/bin/time -f "%e" ./benchmarkRL-resilientv1 $MAP_SIZE 2>&1)"
# echo "resilient-v1-ecfkl: $(/usr/bin/time -f "%e" ./benchmarkRL-resilientv1ecfkl $MAP_SIZE 2>&1)"
echo "resilient-v3: $(/usr/bin/time -f "%e" ./benchmarkRL-resilientv3 $MAP_SIZE 2>&1)"
# echo "resilient-v3-ecfkl: $(/usr/bin/time -f "%e" ./benchmarkRL-resilientv3ecfkl $MAP_SIZE 2>&1)"

echo "unsafe-fast: $(/usr/bin/time -f "%e" ./benchmarkRL-unsafefast $MAP_SIZE 2>&1)"
echo "naive-rc: $(/usr/bin/time -f "%e" ./benchmarkRL-naiverc $MAP_SIZE 2>&1)"
# echo "assist: $(/usr/bin/time -f "%e" ./benchmarkRL-assist $MAP_SIZE 2>&1)"
# echo "resilient-v1: $(/usr/bin/time -f "%e" ./benchmarkRL-resilientv1 $MAP_SIZE 2>&1)"
# echo "resilient-v1-ecfkl: $(/usr/bin/time -f "%e" ./benchmarkRL-resilientv1ecfkl $MAP_SIZE 2>&1)"
echo "resilient-v3: $(/usr/bin/time -f "%e" ./benchmarkRL-resilientv3 $MAP_SIZE 2>&1)"
# echo "resilient-v3-ecfkl: $(/usr/bin/time -f "%e" ./benchmarkRL-resilientv3ecfkl $MAP_SIZE 2>&1)"

echo "unsafe-fast: $(/usr/bin/time -f "%e" ./benchmarkRL-unsafefast $MAP_SIZE 2>&1)"
echo "naive-rc: $(/usr/bin/time -f "%e" ./benchmarkRL-naiverc $MAP_SIZE 2>&1)"
# echo "assist: $(/usr/bin/time -f "%e" ./benchmarkRL-assist $MAP_SIZE 2>&1)"
# echo "resilient-v1: $(/usr/bin/time -f "%e" ./benchmarkRL-resilientv1 $MAP_SIZE 2>&1)"
# echo "resilient-v1-ecfkl: $(/usr/bin/time -f "%e" ./benchmarkRL-resilientv1ecfkl $MAP_SIZE 2>&1)"
echo "resilient-v3: $(/usr/bin/time -f "%e" ./benchmarkRL-resilientv3 $MAP_SIZE 2>&1)"
# echo "resilient-v3-ecfkl: $(/usr/bin/time -f "%e" ./benchmarkRL-resilientv3ecfkl $MAP_SIZE 2>&1)"
