<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class Cors
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        // Permitir el origen del frontend
        $origin = $request->header('Origin');
        
        // Lista de orígenes permitidos
        $allowedOrigins = [
            'http://192.168.1.24:4200',
            'http://localhost:4200',
        ];

        // Verificar si el origen está en la lista permitida o permitir todos en desarrollo
        if (in_array($origin, $allowedOrigins) || env('APP_ENV') === 'local') {
            header('Access-Control-Allow-Origin: ' . ($origin ?: '*'));
        } else {
            header('Access-Control-Allow-Origin: *');
        }

        header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS, PATCH');
        header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, Accept, Origin, X-CSRF-TOKEN');
        header('Access-Control-Allow-Credentials: true');
        header('Access-Control-Max-Age: 86400');

        // Responder a las peticiones OPTIONS (preflight)
        if ($request->getMethod() === 'OPTIONS') {
            return response()->json(['status' => 'OK'], 200);
        }

        return $next($request);
    }
}

