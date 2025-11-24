<?php

declare(strict_types=1);

function factorial(int $number): int
{
    if ($number === 0) {
        return 1;
    } else {
        return $number * factorial($number - 1);
    }
}

/**
 * @param int $number >= 0
 * @return the nth Fibonacci number
 */
function fibonacci(int $number): int
{
    if ($number === 0 || $number === 1) {
        return 1; // base cases
    } else {
        return fibonacci($number - 1) + fibonacci($number - 2); // recursive step
    }
}

$number = 5;
// echo sprintf("Factorial value of %d is %d ",$number,factorial($number)) . PHP_EOL;

echo sprintf("Fibonacia value of %d is %d ", $number, fibonacci($number)) . PHP_EOL;
