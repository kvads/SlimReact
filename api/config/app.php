<?php
declare(strict_types=1);

use Psr\Container\ContainerInterface;
use Slim\Factory\AppFactory;
use Slim\App;

return static function (ContainerInterface  $container): App {
    $app = AppFactory::createFromContainer($container);
    (require __DIR__ . '/middleware.php') ($app, $container);
    (require __DIR__ . '/routes.php') ($app);
    return $app;
};