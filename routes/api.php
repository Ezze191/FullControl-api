<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\ProductosController;

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

Route::get('/Productos', [ProductosController::class, 'index']);

Route::post('/InsertarProducto', [ProductosController::class, 'store']);

Route::get('/Productosid/{id}', [ProductosController::class, 'MostrarProducto']);

Route::get('/ProductoNombre/{nombre}', [ProductosController::class, 'BuscarPorNombre']);

Route::get('/ProductoPLU/{plu}', [ProductosController::class, 'BuscarPorPLU']);

Route::put('/actualizar/{id}', [ProductosController::class, 'update']);

Route::post('/Producto/ActualizarIMG', [ProductosController::class, 'subirImagen']);

Route::delete('/eliminar/{id}', [ProductosController::class, 'destroy']);
