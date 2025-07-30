<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class MaterialsModel extends Model
{
    use HasFactory;

    protected $table = 'materials';

    public $timestamps = false;

    protected $primaryKey = 'id';

    protected $fillable = [
        'id',
        'name',
        'existence',
        'price',
        'supplier',
        'buyLink',
        'lastIncome',
        'imagePath'
    ];

}
