<?php

declare(strict_types=1);

use Slim\App;

return static function (App $app, \Psr\Container\ContainerInterface $container): void {
    $app->addErrorMiddleware($container->get('config')['debug'], true, true);
};
