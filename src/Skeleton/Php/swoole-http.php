<?php
declare(strict_types = 1);


$host = '127.0.0.1';
$post = 8090;
$http = new Swoole\HTTP\Server($host, $post);

$http->on(
    'request', function ($request, $response) {
        $response->end("<h1>Hello World. #".rand(1000, 9999)."</h1>");
    }
);

echo sprintf("Server listening at %s:%d", $host, $post);
$http->start();

