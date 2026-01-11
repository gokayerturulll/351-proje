#!/bin/bash
# CSE351 DCE Project - Run Script

echo "Compiling"
make clean
make

echo ""
echo "Running Test 1"
./dce < tests/test1.il

echo ""
echo "Running Test 2"
./dce < tests/test2.il

echo ""
echo "Running Test 3"
./dce < tests/test3.il

echo ""
echo "Running Test 4"
./dce < tests/test4.il
