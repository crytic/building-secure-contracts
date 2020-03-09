#!/usr/bin/env bash


install_echidna(){
    pip install crytic-compile
    wget https://github.com/crytic/echidna/releases/download/v1.2.0.0/echidna-test-1.2.0.0-Ubuntu-18.04.tar.gz
    tar -xvf echidna-test-1.2.0.0-Ubuntu-18.04.tar.gz
    sudo mv echidna-test /usr/bin/
}

test_example(){
    cd example

    echidna-test testtoken.sol TestToken > results.txt
    if [ $? -ne 1 ]
    then
        echo "testtoken.sol failed"
        exit -1
    fi

    grep "echidna_balance_under_1000: failed!" results.txt
    if [ $? -ne 0 ]
    then
        echo "Bug not found"
        echo "testtoken.sol failed"
        exit -1
    fi

    echo "testtoken.sol passed"
    
    echidna-test assert.sol --config assert.yaml > results.txt
    
    if [ $? -ne 1 ]
    then
        echo "assert.sol failed"
        exit -1
    fi

    grep "assertion in inc: failed!" results.txt
    if [ $? -ne 0 ]
    then
        echo "Bug not found"
        echo "assert.sol failed"
        exit -1
    fi

    echo "assert.sol passed"

    cd ..
}

test_exercise(){
    cd "exercises/exercise$1"

    echidna-test solution.sol TestToken > results.txt 
    if [ $? -ne 1 ]
    then
        echo "Bug not found"
        echo "exercise $1 failed"
        exit -1
    fi

    grep "$2" results.txt
    if [ $? -ne 0 ]
    then
        echo "Bug not found"
        echo "exercise $1 failed"
        exit -1
    fi

    echo "exercise $1 passed"
    cd ../..
}

cd program-analysis/echidna
install_echidna

test_example

test_exercise 1 "echidna_no_transfer: failed!"
test_exercise 2 "echidna_test_balance: failed!"
test_exercise 3 "echidna_test_balance: failed!"



echo "Echidna tests passed"
