<?php
declare(strict_types = 1);
define('PHP_START', microtime(true));
error_reporting(E_ALL); ini_set('display_errors', '1');
ini_set("display_startup_errors", '1'); ini_set("log_errors", '1');

// (1) vendor autoload
// (2) application instate
// (3) run the snippiest

echo sprintf("[ %s ] take %2.5f mili seconds to
complete",$_SERVER["PHP_SELF"],microtime(true)-PHP_START). PHP_EOL;
