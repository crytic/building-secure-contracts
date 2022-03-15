#!/usr/bin/env bash


install_echidna(){
    pip install crytic-compile slither-analyzer
    wget https://github.com/crytic/echidna/releases/download/v2.0.0/echidna-test-2.0.0-Ubuntu-18.04.tar.gz
    tar -xf echidna-test-2.0.0-Ubuntu-18.04.tar.gz
    sudo mv ./echidna-test /usr/bin/
}

test_example(){
    cd example

    echidna-test testtoken.sol --contract TestToken > results.txt
    if [ $? -ne 1 ]
    then
        echo "testtoken.sol failed"
        exit -1
    fi

    grep "echidna_balance_under_1000:\s*failed" results.txt
    if [ $? -ne 0 ]
    then
        echo "Bug not found"
        echo "testtoken.sol failed"
        exit -1
    fi

    echo "testtoken.sol passed"
    

    echidna-test gas.sol --config gas.yaml > results.txt
    if [ $? -ne 0 ]
    then
        echo "gas.sol failed"
        exit -1
    fi

    grep "f(42,123," results.txt
    if [ $? -ne 0 ]
    then
        echo "Maximum gas estimation not found"
        echo "gas.sol failed"
        exit -1
    fi

    echo "gas.sol passed"
    


    echidna-test multi.sol --config filter.yaml > results.txt
    if [ $? -ne 1 ]
    then
        echo "multi.sol failed"
        exit -1
    fi

    grep "echidna_state4:\s*failed" results.txt
    if [ $? -ne 0 ]
    then
        echo "Bug not found"
        echo "multi.sol failed"
        exit -1
    fi

    echo "multi.sol passed"
    


    echidna-test assert.sol --config assert.yaml > results.txt
    
    if [ $? -ne 1 ]
    then
        echo "assert.sol failed"
        exit -1
    fi

    grep "inc(uint256):\s*failed" results.txt
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

    echidna-test solution.sol --contract TestToken > results.txt 
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

test_exercise 1 "echidna_test_balance:\s*failed"
test_exercise 2 "echidna_no_transfer:\s*failed"
test_exercise 3 "echidna_test_balance:\s*failed"



echo "Echidna tests passed"
