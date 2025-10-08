import type { Knex } from "knex";


export async function up(knex: Knex) {
    await knex.schema.createTable('todos', (table) => {
        table.increments('id').primary();
        table.string('text', 255).notNullable();
        table.boolean('completed').notNullable().defaultTo(false);
    });
}

export async function down(knex: Knex) {
    await knex.schema.dropTableIfExists('todos');
}


