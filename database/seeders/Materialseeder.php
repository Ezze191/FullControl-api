<?php

namespace Database\Seeders;


use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class Materialseeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {

        $this->create(10);
    }

    public function create($number)
    {
        for ($i = 0; $i < $number; $i++) {
            DB::Table('materials')->insert([
                'name' => Str::random(10),
                'existence' => 3,
                'price' => 500,
                'supplier' => Str::random(100),
                'buyLink' => Str::random(300),
                'lastIncome' => date_create(),
                'imagePath' => Str::random(400),
            ]);
        }

    }

    public function delete()
    {
        DB::Table('materials')->truncate();
    }
}
