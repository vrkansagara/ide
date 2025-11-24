<?php
declare(strict_types = 1);

$startTime = microtime(true);

error_reporting(E_ALL);
ini_set('display_errors', '-1');
ini_set('display_startup_errors', '0');
ini_set('log_errors', '-1');

echo sprintf('Swoole version is %s', swoole_version()) .PHP_EOL;
echo sprintf('Swoole has total cpu [ %s ]', swoole_cpu_num()) . PHP_EOL;


$xTimes = 10;

echo '------------------------------------------------------------';
Co\run(
    function () use ($xTimes) {
        for ($c = $xTimes; $c--;) {
            go(
                function () use ($xTimes,$c) {
                    $sleepTime = 0;
                    if(( $c%2 ) != 0 ) {
                        $sleepTime = 1;
                    }else{
                        $sleepTime = 2;
                    }
                    sleep($sleepTime);
                    echo 'Thread = $c Sleep $sleepTime '    .PHP_EOL;
                    for ($n = $xTimes; $n--;) {
                        echo $n . PHP_EOL;
                    }
                }
            );
        }
    }
);
echo 'use ' . (microtime(true) - $startTime) . ' s';
