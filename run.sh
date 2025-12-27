#!/bin/bash
# CSE351 DCE Project - Run Script

echo "Derleniyor..."
make clean
make

echo ""
echo "Test 1 çalıştırılıyor..."
./dce < tests/test1.il

echo ""
echo "Test 2 çalıştırılıyor..."
./dce < tests/test2.il
