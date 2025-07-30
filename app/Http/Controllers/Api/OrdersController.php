<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Database\Eloquent\Casts\Json;
use Illuminate\Http\Request;
use App\Models\ordersModel as OrdersModel;
use PhpParser\Node\Expr\FuncCall;
use Symfony\Contracts\Service\Attribute\Required;
use App\Models\VentasModel as VentasModel;
class OrdersController extends Controller
{
    //
    public function index()
    {

        $orders = OrdersModel::orderBy('date', 'DESC')->where('finished', 0)->get();

        return response()->json($orders);
    }

    public function store(Request $request)
    {

        $request->validate([
            'date' => 'required|date',
            'description' => 'required|string|max:255',
            'customerName' => 'required|string|max:255',
            'phoneNumber' => 'numeric',
            'price' => 'required|numeric'
        ]);

        $order = OrdersModel::create($request->all());

        return response()->json([
            'message' => 'ORDEN CREADA CORRECTAMENTE'
        ]);

    }

    public function getAll()
    {
        $order = OrdersModel::all();

        return response()->json($order);
    }

    public function getOnlyFinish()
    {
        $order = OrdersModel::where('finished', true)->get();

        return response()->json($order);
    }

    public function getNotFinish()
    {
        $order = OrdersModel::where('finished', false)->get();

        return response()->json($order);
    }

    public function update(Request $request, $id)
    {

        $order = OrdersModel::where('id', $id)->first();

        if (!$order) {
            return response()->json([
                'error' => 'LA ORDEN NO EXISTE'
            ], 400);
        }

        $data = $request->validate([
            'date' => 'date',
            'description' => 'string|max:255',
            'customerName' => 'string|max:255',
            'phoneNumber' => 'numeric',
            'price' => 'numeric'
        ]);


        $order->update($data);

        return response()->json([
            'message' => 'Orden Actualizada',
            'orden' => $order
        ]);

    }

    public function delete($id)
    {

        $order = ordersModel::where('id', $id)->first();

        if (!$order) {
            return response()->json([
                'error' => 'La orden no existe'
            ]);
        }

        $order->delete();

        return response()->json([
            'message' => 'Orden : ' . $order->description . ' eliminada correctamente'
        ]);

    }

    public function finish($id)
    {

        $order = ordersModel::where('id', $id)->first();

        if (!$order) {
            return response()->json([
                'message' => 'La orden no existe'
            ]);
        }

        $order->finished = true;



        $order->save();


        return response()->json([
            'message' => 'Orden : ' . $order->description . ' terminada'
        ]);

    }

    public function notFinish($id)
    {
        $order = ordersModel::where('id', $id)->first();

        if (!$order) {
            return response()->json([
                'message' => 'La orden no existe'
            ]);
        }

        $order->finished = false;

        $order->save();


        return response()->json([
            'message' => 'Orden : ' . $order->description . ' terminada'
        ]);
    }

    public function cobrar($id)
    {

        $orden = OrdersModel::where('id', $id)->first();

        if (!$orden) {
            return response()->json([
                'message' => 'la orden no existe'
            ], 404);
        }

        $dinero_ganado = $orden->price;

        $date = now()->format(format: 'y-m-d');

        $ventas_data = [
            'ID_PRODUCT' => $id,
            'PRODUCT_NAME' => $orden->description,
            'FECHA' => $date,
            'EXISTENCIA_DE_SALIDA' => 1,
            'DINERO_GENERADO' => $dinero_ganado
        ];

        $existe_venta = VentasModel::where('ID_PRODUCT', $id)->whereDate('FECHA', $date)->first();

        if ($existe_venta) {
            $existencia_venta = $existe_venta->EXISTENCIA_DE_SALIDA + 1;
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
