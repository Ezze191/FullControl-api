<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Auth\Events\Validated;
use Illuminate\Http\Request;
use App\Models\MaterialsModel as MaterialsModel;

class MaterialsController extends Controller
{
    //get all materials
    public function index()
    {
        $materials = MaterialsModel::all();
        return response()->json($materials);
    }

    //inset a material
    public function store(Request $request)
    {

        $request->validate([
            'name' => 'required|string|max:255|unique:materials',
            'existence' => 'required|numeric',
            'price' => 'required|numeric',
            'supplier' => 'required|string|max:255',
            'buyLink' => 'string|max:500',
            'lastIncome' => 'required|date',
            'imagePath' => 'string|max:500'
        ]);



        $material = MaterialsModel::create($request->all());
        return response()->json([
            'message' => 'Material insert successfully'
        ], 201);
    }

    //updated material

    public function update(Request $request, $id)
    {

        $material = MaterialsModel::where('id', $id)->first();

        if (!$material) {
            return response()->json([
                'error' => 'EL MATERIAL NO EXISTE'
            ], 404);
        }

        $data = $request->validate([
            'name' => 'string|max:255',
            'existence' => 'numeric',
            'price' => 'numeric',
            'supplier' => 'string|max:255',
            'buyLink' => 'string|max:1500',
            'lastIncome' => 'date',
            'imagePath' => 'string|max:500'
        ]);

        $material->update($data);

        return response()->json([
            'message' => 'MATERIAL ACTUALIZADO'
        ]);


    }

    public function delete($id)
    {

        $material = MaterialsModel::where('id', $id)->first();


        if (!$material) {
            return response()->json([
                'error' => 'NO EXISTE EL MATERIAL'
            ]);
        }

        $material->delete();

        return response()->json([
            'message' => ' ELIMINADO CORRECTAMENTE'
        ]);
    }

    public function BuscarPorNombre($nombre)
    {

        $material = MaterialsModel::where('name', 'LIKE', "%{$nombre}%")->get();

        if ($material->isEmpty()) {
            return response()->json([
                'error' => 'No hay ningun Producto con este nombre'
            ], 404);
        }

        return response()->json($material);
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
