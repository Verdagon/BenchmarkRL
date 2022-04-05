#!/bin/bash

if [ "$1" == "" ] ; then
  echo "First arg should be path to the compiler"
  exit 1
fi
VALE_COMPILER_DIR="$1"

if [ "$2" == "" ] ; then
  STDLIB_DIR="$VALE_COMPILER_DIR/stdlib"
  echo "Defaulting to stdlib in $STDLIB_DIR."
else
  STDLIB_DIR="$2"
fi

MAP_SIZE=500


$VALE_COMPILER_DIR/valec build benchmarkrl=src stdlib=$STDLIB_DIR/src --output_dir build --region_override unsafe-fast -o benchmarkRL-unsafefast || exit 1
cp build/benchmarkRL-unsafefast .
$VALE_COMPILER_DIR/valec build benchmarkrl=src stdlib=$STDLIB_DIR/src --output_dir build --region_override naive-rc -o benchmarkRL-naiverc || exit 1
cp build/benchmarkRL-naiverc .
$VALE_COMPILER_DIR/valec build benchmarkrl=src stdlib=$STDLIB_DIR/src --output_dir build --region_override resilient-v3 -o benchmarkRL-resilientv3 || exit 1
cp build/benchmarkRL-resilientv3 .

# Now, begin the benchmarking!
# 1. Copy this output into an editor like sublime
# 2. Sort it to group the times by mode
# 3. Take out the best and worst number for each (outliers)
# 4. Average the remaining ones for each

echo "unsafe-fast: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-unsafefast $MAP_SIZE 2>&1)"
echo "naive-rc: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-naiverc $MAP_SIZE 2>&1)"
# echo "assist: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-assist $MAP_SIZE 2>&1)"
# echo "resilient-v1: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-resilientv1 $MAP_SIZE 2>&1)"
# echo "resilient-v1-ecfkl: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-resilientv1ecfkl $MAP_SIZE 2>&1)"
echo "resilient-v3: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-resilientv3 $MAP_SIZE 2>&1)"
# echo "resilient-v3-ecfkl: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-resilientv3ecfkl $MAP_SIZE 2>&1)"

echo "unsafe-fast: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-unsafefast $MAP_SIZE 2>&1)"
echo "naive-rc: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-naiverc $MAP_SIZE 2>&1)"
# echo "assist: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-assist $MAP_SIZE 2>&1)"
# echo "resilient-v1: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-resilientv1 $MAP_SIZE 2>&1)"
# echo "resilient-v1-ecfkl: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-resilientv1ecfkl $MAP_SIZE 2>&1)"
echo "resilient-v3: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-resilientv3 $MAP_SIZE 2>&1)"
# echo "resilient-v3-ecfkl: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-resilientv3ecfkl $MAP_SIZE 2>&1)"

echo "unsafe-fast: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-unsafefast $MAP_SIZE 2>&1)"
echo "naive-rc: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-naiverc $MAP_SIZE 2>&1)"
# echo "assist: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-assist $MAP_SIZE 2>&1)"
# echo "resilient-v1: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-resilientv1 $MAP_SIZE 2>&1)"
# echo "resilient-v1-ecfkl: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-resilientv1ecfkl $MAP_SIZE 2>&1)"
echo "resilient-v3: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-resilientv3 $MAP_SIZE 2>&1)"
# echo "resilient-v3-ecfkl: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-resilientv3ecfkl $MAP_SIZE 2>&1)"

echo "unsafe-fast: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-unsafefast $MAP_SIZE 2>&1)"
echo "naive-rc: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-naiverc $MAP_SIZE 2>&1)"
# echo "assist: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-assist $MAP_SIZE 2>&1)"
# echo "resilient-v1: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-resilientv1 $MAP_SIZE 2>&1)"
# echo "resilient-v1-ecfkl: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-resilientv1ecfkl $MAP_SIZE 2>&1)"
echo "resilient-v3: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-resilientv3 $MAP_SIZE 2>&1)"
# echo "resilient-v3-ecfkl: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-resilientv3ecfkl $MAP_SIZE 2>&1)"

echo "unsafe-fast: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-unsafefast $MAP_SIZE 2>&1)"
echo "naive-rc: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-naiverc $MAP_SIZE 2>&1)"
# echo "assist: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-assist $MAP_SIZE 2>&1)"
# echo "resilient-v1: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-resilientv1 $MAP_SIZE 2>&1)"
# echo "resilient-v1-ecfkl: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-resilientv1ecfkl $MAP_SIZE 2>&1)"
echo "resilient-v3: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-resilientv3 $MAP_SIZE 2>&1)"
# echo "resilient-v3-ecfkl: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-resilientv3ecfkl $MAP_SIZE 2>&1)"

echo "unsafe-fast: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-unsafefast $MAP_SIZE 2>&1)"
echo "naive-rc: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-naiverc $MAP_SIZE 2>&1)"
# echo "assist: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-assist $MAP_SIZE 2>&1)"
# echo "resilient-v1: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-resilientv1 $MAP_SIZE 2>&1)"
# echo "resilient-v1-ecfkl: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-resilientv1ecfkl $MAP_SIZE 2>&1)"
echo "resilient-v3: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-resilientv3 $MAP_SIZE 2>&1)"
# echo "resilient-v3-ecfkl: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-resilientv3ecfkl $MAP_SIZE 2>&1)"

echo "unsafe-fast: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-unsafefast $MAP_SIZE 2>&1)"
echo "naive-rc: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-naiverc $MAP_SIZE 2>&1)"
# echo "assist: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-assist $MAP_SIZE 2>&1)"
# echo "resilient-v1: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-resilientv1 $MAP_SIZE 2>&1)"
# echo "resilient-v1-ecfkl: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-resilientv1ecfkl $MAP_SIZE 2>&1)"
echo "resilient-v3: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-resilientv3 $MAP_SIZE 2>&1)"
# echo "resilient-v3-ecfkl: $(/usr/local/bin/gtime -f "%e" ./benchmarkRL-resilientv3ecfkl $MAP_SIZE 2>&1)"
