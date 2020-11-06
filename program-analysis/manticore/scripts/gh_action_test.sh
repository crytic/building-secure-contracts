#!/usr/bin/env bash

test_example(){
    cd examples

    python $1
    if [ $? -ne 0 ]
    then
        echo "$1 failed"
        exit -1
    fi

    echo "$1 passed"
    cd ..
}


test_exercise_example(){
    cd "exercises/example"

    python my_token.py > results.txt 
    if [ $? -ne 0 ]
    then
        echo "my_token.py failed"
        exit -1
    fi

    grep "Bug found" results.txt
    if [ $? -ne 0 ]
    then
        echo "Bug not found"
        echo "my_token.py failed"
        exit -1
    fi

    echo "my_token.py passed"
    cd ../..
}


test_exercise(){
    cd "exercises/exercise$1"

    python solution.py > results.txt 
    if [ $? -ne 0 ]
    then
        echo "exercise $1 failed"
        exit -1
    fi

    grep "Bug found" results.txt
    if [ $? -ne 0 ]
    then
        "Bug not found"
        echo "exercise $1 failed"
        exit -1
    fi

    echo "exercise $1 passed"
    cd ../..
}



pip install manticore

cd program-analysis/manticore

sudo add-apt-repository ppa:sri-csl/formal-methods -y
sudo apt-get update
sudo apt-get install yices2

test_example example_run.py
test_example example_throw.py
test_example example_constraint.py

test_exercise_example

test_exercise 1
test_exercise 2

echo "Manticore tests passed"
