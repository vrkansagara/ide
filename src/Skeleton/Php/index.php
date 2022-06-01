<?php

declare(strict_types=1);

define('PHP_START', microtime(true));

require_once '/home/vallabh/.vim/vendor/autoload.php';

echo 'List down all the default constant defined by the php ';
print_r(get_defined_constants(true));

// $dt = new DateTime('2019-02-01T03:45:27+00:00');
$dt = new DateTime();
$array = [];

var_dump($dt);

echo sprintf( '[ %s ] take %2.5f milliseconds  to complete',
    $_SERVER['PHP_SELF'], microtime(true) - PHP_START) . PHP_EOL;

$dt = ' I am new date string';

echo (string) "This is date $dt";

