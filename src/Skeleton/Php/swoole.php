<?php
declare(strict_types = 1);
$s = microtime(true);

$xTimes = 10;

echo '------------------------------------------------------------';

Co\run(function() use($xTimes){
	for ($c = $xTimes; $c--;) {


		go(function () use($xTimes,$c) {
		$sleepTime = 0;
		if( ( $c%2 ) != 0 ){
			$sleepTime = 1;
		}else{
			$sleepTime = 2;
		}
		sleep($sleepTime);
		echo "Thread = $c Sleep $sleepTime "	.PHP_EOL;
			for ($n = $xTimes; $n--;) {
				echo $n . PHP_EOL;
			}
		});
	}
});
echo 'use ' . (microtime(true) - $s) . ' s';
