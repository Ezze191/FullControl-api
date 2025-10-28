<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Cross-Origin Resource Sharing (CORS) Configuration
    |--------------------------------------------------------------------------
    |
    | Here you may configure your settings for cross-origin resource sharing
    | or "CORS". This determines what cross-origin operations may execute
    | in web browsers. You are free to adjust these settings as needed.
    |
    | To learn more: https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS
    |
    */

    'paths' => ['api/*', 'sanctum/csrf-cookie'],

    'allowed_methods' => ['*'],

    'allowed_origins' => [
        env('FRONTEND_URL', 'http://192.168.1.24:4200'),
        'http://192.168.1.24:4200',
        'http://localhost:4200',
        '*', // Permitir todos los orígenes (para desarrollo)
    ],

    'allowed_origins_patterns' => [
        '/^http:\/\/192\.168\.1\.\d+:\d+$/', // Cualquier IP en la red local
    ],

    'allowed_headers' => ['*'],

    'exposed_headers' => ['Authorization'],

    'max_age' => 86400, // 24 horas

    'supports_credentials' => true,

];
