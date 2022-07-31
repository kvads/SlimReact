<?php
declare(strict_types=1);

use Slim\Factory\AppFactory;
use App\Http\Action\HomeAction;

http_response_code(500);
require __DIR__ . '/../vendor/autoload.php';


$builder = new DI\ContainerBuilder();
$builder->addDefinitions([
    'config' => [
        'debug' => (bool) getenv('DEBUG_MODE')
    ],
    HomeAction::class => function () {
        return new HomeAction(new \Slim\Psr7\Factory\ResponseFactory());
    }
]);
$container = $builder->build();

$app = AppFactory::createFromContainer($container);

$app->addErrorMiddleware($container->get('config')['debug'], true, true);

$app->get('/', HomeAction::class);

$app->run();