<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// Health check endpoint
Route::get('/health', function () {
    return response()->json([
        'status' => 'ok',
        'message' => 'API is running',
        'timestamp' => now()->toISOString(),
        'environment' => app()->environment(),
    ]);
});

// Test endpoint para verificar CORS
Route::get('/test', function () {
    return response()->json([
        'message' => 'API Test successful',
        'cors' => 'enabled',
        'server_ip' => request()->server('SERVER_ADDR'),
        'client_ip' => request()->ip(),
    ]);
});

// Tus rutas API aquí
Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

// Ejemplo de rutas CRUD
// Route::apiResource('items', ItemController::class);
