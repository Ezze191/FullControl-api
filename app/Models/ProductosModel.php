<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ProductosModel extends Model
{
    protected $table = 'productos';
    public $timestamps = false;  

    protected $primaryKey = 'ID_PRODUCT';
    protected $fillable = [
        'PLU',
        'NOMBRE',
        'EXISTENCIA',
        'PRECIO_COMPRA',
        'PRECIO_VENTA',
        'GANANCIA',
        'PROVEDOR',
        'ULTIMO_INGRESO',
        'IMAGE_PATH'
    ];
}
