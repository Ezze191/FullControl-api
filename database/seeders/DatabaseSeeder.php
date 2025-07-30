<?php

namespace Database\Seeders;

// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;


class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        DB::statement('SET FOREIGN_KEY_CHECKS=0;');

        DB::table('materials')->truncate();
        DB::table('migrations')->truncate();
        DB::table('orders')->truncate();
        DB::table('personal_access_tokens')->truncate();
        DB::table('productos')->truncate();
        DB::table('services')->truncate();
        DB::table('ventas')->truncate();

        DB::statement('SET FOREIGN_KEY_CHECKS=1;');
    }


}
