pragma solidity 0.4.19;


contract Fibonacci {
    /* Carry out calculations to find the nth Fibonacci number */
    function fibRecur(uint n) public pure returns (uint) {
        if (n == 0 || n == 1) {
            return 1;
        } else {
            return fibRecur(n - 1) + fibRecur(n - 2);
        }
    }

    /* Carry out calculations to find the nth Fibonacci number */
    function fibIter(uint n) public returns (uint) {
        uint fib = 1;
        uint last_fib = fib;
        for (uint i = 0; i < n - 1; i++) {
            uint new_fib = fib + last_fib;
            last_fib = fib;
            fib = new_fib;
        }
        return fib;
    }
}
