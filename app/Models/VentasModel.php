<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class VentasModel extends Model
{
    use HasFactory;

    protected $table = 'ventas';

    protected $primaryKey = 'ID';

    public $timestamps = false;


    protected $fillable = [
        'ID',
        'ID_PRODUCT',
        'PRODUCT_NAME',
        'FECHA',
        'EXISTENCIA_DE_SALIDA',
        'DINERO_GENERADO'
    ];


}
