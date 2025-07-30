<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\ProductosModel as ProductosModel;
use App\Models\VentasModel as VentasModel;
use App\Models\MaterialsModel as MaterialModel;

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
                'error' => 'No hay ningun Producto con este nombre'
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
            'PLU' => 'numeric',
            'NOMBRE' => 'string|max:255',
            'EXISTENCIA' => 'integer',
            'PRECIO_COMPRA' => 'numeric',
            'PRECIO_VENTA' => 'numeric',
            'PROVEDOR' => 'string|max:255',
            'ULTIMO_INGRESO' => 'date',
            'IMAGE_PATH' => 'string|max:500'
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

            // Mover directo a public/assets/img
            $file->move(public_path('assets/img'), $nombre);

            // Generar URL completa
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

    //cobrar un producto
    public function cobrar(Request $request, $id, $unidades)
    {
        $producto = ProductosModel::where('ID_PRODUCT', $id)->first();

        if (!$producto) {
            return response()->json([
                'message' => 'El producto no existe'
            ], 404);
        }


        $dinero_ganado = $producto->PRECIO_VENTA * $unidades;
        $producto->EXISTENCIA -= $unidades;
        $producto->save();


        $date = now()->format('Y-m-d');

        $ventas_data = [
            'ID_PRODUCT' => $id,
            'PRODUCT_NAME' => $producto->NOMBRE,
            'FECHA' => $date,
            'EXISTENCIA_DE_SALIDA' => $unidades,
            'DINERO_GENERADO' => $dinero_ganado
        ];

        $existe_venta = VentasModel::where('ID_PRODUCT', $id)->whereDate('FECHA', $date)->first();

        if ($existe_venta) {
            $existencia_venta = $existe_venta->EXISTENCIA_DE_SALIDA + $unidades;
            $dinero_venta = $existe_venta->DINERO_GENERADO + $dinero_ganado;

            $existe_venta->EXISTENCIA_DE_SALIDA = $existencia_venta;
            $existe_venta->DINERO_GENERADO = $dinero_venta;

            $existe_venta->save();

            return response()->json([
                'venta_actualizada' => $existe_venta
            ], 201);
        }


        $venta_creada = VentasModel::create($ventas_data);

        return response()->json([
            'message' => 'VENTA GENERADA CORRECTAMENTE',
            'venta_creada' => $venta_creada
        ], 201);
    }

}
