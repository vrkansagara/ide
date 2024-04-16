<?php declare(strict_types=1);
// uuidgen | pbcopy

define('PHP_START', microtime(true));

/**
 * This makes our life easier when dealing with paths. Everything is relative
 * to the application root now.
 */
chdir(dirname(__DIR__));

// Decline static file requests back to the PHP built-in webserver
if (php_sapi_name() === 'cli-server') {
    $path = realpath(__DIR__ . parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH));
    if (is_string($path) && __FILE__ !== $path && is_file($path)) {
        return false;
    }
    unset($path);
}
// Composer autoloading
require_once __DIR__ . '/../vendor/autoload.php';


$uuid = Uuid::uuid4();

printf(
    "UUID: %s\nVersion: %d\n",
    $uuid->toString(),
    $uuid->getFields()->getVersion()
);

echo sprintf('[ %s ] take %2.5f milliseconds  to complete', $_SERVER['PHP_SELF'], microtime(true) - PHP_START) . PHP_EOL;