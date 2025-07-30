<?php

use App\Http\Controllers\Api\MaterialsController;
use App\Http\Controllers\Api\OrdersController;
use Illuminate\Http\Request;
use Illuminate\Routing\Router;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\ProductosController;
use App\Http\Controllers\Api\VentasController;
use App\Http\Controllers\Api\ServicesController;



//Productos
Route::get('/Productos', [ProductosController::class, 'index']);

Route::post('/InsertarProducto', [ProductosController::class, 'store']);

Route::get('/Productosid/{id}', [ProductosController::class, 'MostrarProducto']);

Route::get('/ProductoNombre/{nombre}', [ProductosController::class, 'BuscarPorNombre']);

Route::get('/ProductoPLU/{plu}', [ProductosController::class, 'BuscarPorPLU']);

Route::put('/actualizar/{id}', [ProductosController::class, 'update']);

Route::post('/Producto/ActualizarIMG', [ProductosController::class, 'subirImagen']);

Route::delete('/eliminar/{id}', [ProductosController::class, 'destroy']);

Route::post('/cobrar/{id}/{unidades}', [ProductosController::class, 'cobrar']);

//ventas
Route::get('/Ventas', [VentasController::class , 'index']);

//materials
$materialName = 'materials';
Route::get($materialName.'/materials' , [MaterialsController::class , 'index']);
Route::post($materialName.'/insert' , [MaterialsController::class , 'store']);
Route::put($materialName.'/update/{id}' , [MaterialsController::class , 'update']);
Route::delete($materialName.'/delete/{id}' , [MaterialsController::class , 'delete']);
Route::post($materialName.'/subirImagen', [MaterialsController::class, 'subirImagen']);
Route::get($materialName.'/buscarpornombre/{nombre}', [MaterialsController::class, 'BuscarPorNombre']);
//orders
$ordersName = 'orders';
Route::get($ordersName.'/all' , [OrdersController::class , 'getAll']);
Route::get($ordersName.'/orders' , [OrdersController::class , 'index']);
Route::get($ordersName.'/getFinished' , [OrdersController::class , 'getOnlyFinish']);
Route::get($ordersName.'/getNotFinished' , [OrdersController::class , 'getNotFinish']);
Route::post($ordersName.'/insert' , [OrdersController::class , 'store']);
Route::put($ordersName.'/update/{id}' , [OrdersController::class , 'update']);
Route::post($ordersName.'/finish/{id}', [OrdersController::class , 'finish']);
Route::post($ordersName.'/notfinish/{id}', [OrdersController::class , 'notFinish']);
Route::delete($ordersName.'/delete/{id}' , [OrdersController::class, 'delete']);
Route::post($ordersName.'/cobrar/{id}', [OrdersController::class , 'cobrar']);
//services
$serviceName = 'services';
Route::get($serviceName.'/all', [ServicesController::class , 'index']);
Route::get($serviceName.'/findbyid/{id}', action: [ServicesController::class , 'findbyid']);
Route::get($serviceName.'/findbyname/{nombre}', [ServicesController::class , 'findbyname']);
Route::post($serviceName.'/insert', [ServicesController::class , 'store']);
Route::put($serviceName.'/update/{id}', [ServicesController::class , 'update']);
Route::delete($serviceName.'/delete/{id}', [ServicesController::class , 'delete']);
Route::post($serviceName.'/cobrar/{id}', [ServicesController::class , 'cobrar']);
Route::post($serviceName.'/subirImagen', [ServicesController::class, 'subirImagen']);
