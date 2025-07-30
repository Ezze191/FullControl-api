<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\VentasModel as VentasModel;

class VentasController extends Controller
{
    //obtener todas las ventas

    public function index(){
        $ventas = VentasModel::all();
        return response()->json($ventas);
    }
}
