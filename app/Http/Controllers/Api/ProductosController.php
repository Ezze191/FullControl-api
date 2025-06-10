<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\ProductosModel as ProductosModel;

class ProductosController extends Controller
{
    //obtener todos los productos

    public function index()
    {
        $productos = ProductosModel::all();
        return response()->json($productos);
    }

    //insertar un producto
    public function store(Request $request)
    {
        $request->validate([
            'PLU' => 'required|integer|unique:productos',
            'NOMBRE' => 'required|string|max:255',
            'EXISTENCIA' => 'required|integer',
            'PRECIO_COMPRA' => 'required|numeric',
            'PRECIO_VENTA' => 'required|numeric',
            'PROVEDOR' => 'required|string|max:255',
            'ULTIMO_INGRESO' => 'required|date',
            'IMAGE_PATH' => 'required|string|max:500',
        ]);
        $producto = ProductosModel::create($request->all());
        return response()->json([
            'message' => 'Producto Insertado Correctamente'
        ], 201);
    }

    //obtener un producto mediante id
    public function MostrarProducto($id)
    {
        $producto = ProductosModel::where('ID_PRODUCT', $id)->first();
        if (!$producto) {
            return response()->json([
                'message' => 'EL PRODUCTO NO EXISTE'
            ], 404);
        }
        return response()->json($producto);
    }

    //buscar mediante nombre
    public function BuscarPorNombre($nombre)
    {
        $producto = ProductosModel::where('NOMBRE', 'LIKE', "%{$nombre}%")->get();

        if ($producto->isEmpty()) {
            return response()->json([
                'message' => 'No hay ningun Producto con este nombre'
            ], 404);
        }

        return response()->json($producto);
    }

    //buscar por PLU
    public function BuscarPorPLU($plu)
    {
        $producto = ProductosModel::where('PLU', $plu)->first();

        if (!$producto) {
            return response()->json([
                'message' => 'PLU NO ENCONTRADO'
            ], 404);
        }
        return response()->json($producto);
    }


    //actualizar un producto mediante id

    public function update(Request $request, $id)
    {
        $producto = ProductosModel::where('ID_PRODUCT', $id)->first();

        if (!$producto) {
            return response()->json([
                'message' => 'El producto no existe'
            ], 404);
        }

        $data = $request->validate([
            'PLU' => 'required|numeric',
            'NOMBRE' => 'required|string|max:255',
            'EXISTENCIA' => 'required|integer',
            'PRECIO_COMPRA' => 'required|numeric',
            'PRECIO_VENTA' => 'required|numeric',
            'PROVEDOR' => 'required|string|max:255',
            'ULTIMO_INGRESO' => 'required|date',
            'IMAGE_PATH' => 'required|string|max:500'
        ]);

        $producto->update($data);
        return response()->json([
            'message' => 'Producto actualizado',
            'Producto' => $producto
        ]);
    }


    //subir una imagen y guardarla en assets/img/
    public function subirImagen(Request $request)
    {

        if ($request->hasFile('imagen')) {
            $file = $request->file('imagen');
            $nombre = time() . '_' . $file->getClientOriginalName();

            $file->storeAs('', $nombre, 'public');

            $urlCompleta = url('assets/img/' . $nombre);

            return response()->json(['ruta' => $urlCompleta]);
        }

        return response()->json(['error' => 'No se recibió archivo'], 400);
    }

    //eliminar un producto mediante id
    public function destroy($id)
    {
        $producto = ProductosModel::where('ID_PRODUCT', $id)->first();

        if (!$producto) {
            return response()->json([
                'message' => 'EL PRODUCTO NO EXISTE'
            ], 404);
        }

        $producto->delete();

        return response()->json([
            'message' => 'Producto eliminado correctamente'
        ]);
    }

}
