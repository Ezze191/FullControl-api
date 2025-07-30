<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Support\Number;

class OrdersSeed extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        //
        $this->create(15);
    }

    public function create($number){

        for($i = 0; $i < $number; $i++){
            DB::Table('orders')->insert([
                'date' => date_create(),
                'description' => Str::random(10),
                'customerName' => Str::random(5),
                'phoneNumber' => rand(1 , 18),
                'price' => rand(100 , 500)
            ]);
        }
    }

    public function delete()
    {
        DB::Table('orders')->truncate();
    }

    
}
