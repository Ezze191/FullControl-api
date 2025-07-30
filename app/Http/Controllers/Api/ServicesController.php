<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\ServicesModel as Services;
use App\Models\VentasModel as Ventas;


class ServicesController extends Controller
{
    //obtener todos los servicios
    public function index()
    {
        $services = Services::all();

        return response()->json($services);
    }

    //obtener un servicio por id
    public function findbyid($id)
    {
        $service = Services::where('id', $id)->first();

        if ($service) {
            return response()->json([
                'error' => 'EL SERVICIO NO EXISTE'
            ]);
        }
    }

    //buscar por nombre
    public function findbyname($nombre)
    {
        $services = Services::where('name', 'LIKE', "%{$nombre}%")->get();


        if ($services->isEmpty()) {
            return response()->json([
                'error' => 'No hay ningun Servicio con este nombre'
            ], 404);
        }

        return response()->json($services);
    }

    //crear un servicio
    public function store(Request $request)
    {

        $request->validate([
            'name' => 'required|string|max:255|unique:services',
            'description' => 'required|string|max:255',
            'commission' => 'required|numeric',
            'imagePath' => 'string|max:500'
        ]);

        $service = Services::create($request->all());

        return response()->json([
            'message' => 'SERVICIO CREADO CORRECTAMENTE'
        ]);

    }

    //actualizar un servicio
    public function update(Request $request, $id)
    {

        $service = Services::where('id', $id)->first();

        if (!$service) {
            return response()->json([
                'error' => 'EL SERVICIO NO EXISTE'
            ]);
        }

        $data = $request->validate([
            'name' => 'string|max:255',
            'description' => 'string|max:255',
            'commission' => 'numeric',
            'imagePath' => 'string|max:500'
        ]);

        $service->update($data);

        return response()->json([
            'message' => 'SERVICIO ACTUALIZADO CORRECTAMENTE'
        ]);
    }

    //eliminar un servicio
    public function delete($id)
    {

        $service = Services::where('id', $id)->first();

        if (!$service) {
            return response()->json(data: [
                'error' => 'EL SERVICIO NO EXISTE'
            ]);
        }

        $service->delete();

        return response()->json([
            'message' => 'SERVICIO ELIMINADO CORRECTAMENTE'
        ]);
    }

    //cobrar un servicio
    public function cobrar($id)
    {

        $service = Services::where('id', $id)->first();

        if (!$service) {
            return response()->json([
                'error' => 'NO SE ENCONTRO NINGUN SERVICIO'
            ]);
        }

        $date = now()->format(format: 'y-m-d');

        $venta_data = [
            'ID_PRODUCT' => $service->id,
            'PRODUCT_NAME' => $service->name,
            'FECHA' => $date,
            'EXISTENCIA_DE_SALIDA' => 1,
            'DINERO_GENERADO' => $service->commission
        ];

        $existe_venta = Ventas::where('ID_PRODUCT', $id)->whereDate('FECHA', $date)->first();

        if ($existe_venta) {
            $existencia_venta = $existe_venta->EXISTENCIA_DE_SALIDA + 1;
            $dinero_venta = $existe_venta->DINERO_GENERADO + $service->commission;

            $existe_venta->EXISTENCIA_DE_SALIDA = $existencia_venta;
            $existe_venta->DINERO_GENERADO = $dinero_venta;

            $existe_venta->save();

            return response()->json([
                'venta_actualizada' => $existe_venta
            ], 201);
        }

        $venta_creada = Ventas::create($venta_data);

        return response()->json([
            'message' => 'VENTA GENERADA CORRECTAMENTE',
            'venta_creada' => $venta_creada
        ], 201);

    }

    public function subirImagen(Request $request)
    {
        if ($request->hasFile('imagen')) {
            $file = $request->file('imagen');
            $nombre = time() . '_' . $file->getClientOriginalName();

            // Mover directo a public/assets/img
            $file->move(public_path('assets/img'), $nombre);

            // Generar URL completa
            $urlCompleta = url('assets/img/' . $nombre);

            return response()->json(['ruta' => $urlCompleta]);
        }

        return response()->json(['error' => 'No se recibió archivo'], 400);
    }

}
