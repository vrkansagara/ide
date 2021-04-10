<?php
declare(strict_types = 1);

error_reporting(E_ALL); ini_set('display_errors', '1'); ini_set('display_startup_errors', '1'); ini_set('log_errors', '1');

$xTimes = 150;

// $s = microtime(true);
// $dbhost = 'localhost';
// $dbname = 'l8';
// $dbusername = 'root';
// $dbpassword = 'toor';

// $mysql = new PDO("mysql:host=$dbhost;dbname=$dbname", $dbusername, $dbpassword);

// $statement = $mysql->prepare("INSERT INTO `users` (`id`, `name`, `email`, `email_verified_at`, `password`, `remember_token`, `created_at`, `updated_at`) VALUES (NULL, 'test', '1test@gmail.com', NULL, '', NULL, now(), now());");

// for ($n = $xTimes; $n--;) {
	// $result = $statement->execute();
// }
	// echo 'use ' . (microtime(true) - $s) . ' s';
// exit;
$s = microtime(true);
Co\run(function() use($xTimes){
	for ($c = $xTimes; $c--;) {
		go(function () use($xTimes){
			$mysql = new Swoole\Coroutine\MySQL;
			$mysql->connect([
				'host' => '127.0.0.1',
				'user' => 'root',
				'password' => 'toor',
				'database' => 'l8'
			]);
			// $statement = $mysql->prepare('SELECT * FROM `users`');
			$statement = $mysql->prepare("INSERT INTO `users` (`id`, `name`, `email`, `email_verified_at`, `password`, `remember_token`, `created_at`, `updated_at`) VALUES (NULL, 'test', '1test@gmail.com', NULL, '', NULL, now(), now());");
			for ($n = $xTimes; $n--;) {
				$result = $statement->execute();
				assert(count($result) > 0);
			}
		});
	}
});
echo 'use ' . (microtime(true) - $s) . ' s';
