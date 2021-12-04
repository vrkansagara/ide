<?php

declare(strict_types=1);

$globalValue = [];

function fibona($i, &$globalValue)
{
    if ($i == 0) {
        return $i;
    }

    if ($i == 1) {
        return $i;
    }

    if (isset($globalValue[$i - 1])) {
        $one = $globalValue[$i - 1];
    } else {
        $one = fibona($i - 1, $globalValue);
    }

    if (isset($globalValue[$i - 2])) {
        echo 1;
        exit;
        $two = $globalValue[$i - 2];
    } else {
        $two = fibona($i - 2, $globalValue);
    }

    return $one + $two;
}

for ($i = 0; $i <= 15; $i++) {
    echo fibona($i, $globalValue) . PHP_EOL;
}
