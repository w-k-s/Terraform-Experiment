const { PostgreSqlContainer } = require("@testcontainers/postgresql");
const { handler, _reset } = require("./index.js");

jest.mock("aws-sdk", () => {
    let mockSecretString;
    return {
        __setSecretString: (value) => { mockSecretString = value; },
        SecretsManager: jest.fn(() => ({
            getSecretValue: jest.fn(() => ({
                promise: async () => ({
                    SecretString: JSON.stringify(mockSecretString),
                }),
            })),
        })),
    };
});

const AWS = require("aws-sdk");

const buildEvent = (method, path, body = null) => ({
    requestContext: { http: { method, path } },
    body: body ? JSON.stringify(body) : null,
});

describe("Todo API", () => {
    let container;
    let connectionString;
    let knex;

    beforeAll(async () => {
        container = await new PostgreSqlContainer("postgres:15-alpine")
            .withDatabase("testdb")
            .withUsername("postgres")
            .withPassword("postgres")
            .start();

        connectionString = container.getConnectionUri();
        process.env.AWS_SECRETSMANAGER_SECRET_NAME = "test-secret";

        AWS.__setSecretString({
            db_conn_string: connectionString,
        });

        // Not ideal :/
        const { Client } = require("pg");
        const client = new Client({ connectionString });
        await client.connect();
        await client.query(`
      CREATE TABLE IF NOT EXISTS todos (
        id SERIAL PRIMARY KEY,
        text TEXT NOT NULL,
        completed BOOLEAN DEFAULT FALSE
      );
    `);
        await client.end();
    }, 30000);

    beforeEach(async () => {
        await _reset();
    });

    afterAll(async () => {
        const Knex = require("knex");
        knex = Knex({
            client: "pg",
            connection: connectionString,
        });
        await knex.destroy();

        if (container) await container.stop();
    });

    test("POST /todo should create a todo", async () => {
        const event = buildEvent("POST", "/todo", { text: "Test item" });
        const res = await handler(event);
        expect(res.statusCode).toBe(201);
        const body = JSON.parse(res.body);
        expect(body.text).toBe("Test item");
    });

    test("GET /todo returns all todos", async () => {
        await handler(buildEvent("POST", "/todo", { text: "One" }));
        await handler(buildEvent("POST", "/todo", { text: "Two" }));

        const res = await handler(buildEvent("GET", "/todo"));
        expect(res.statusCode).toBe(200);
        const body = JSON.parse(res.body);
        expect(body.length).toBe(2);
    });

    test("PATCH /todo/{id} should update an existing todo", async () => {
        await handler(buildEvent("POST", "/todo", { text: "Initial" }));
        const event = buildEvent("PATCH", "/todo/1", { text: "Updated" });
        const res = await handler(event);
        expect(res.statusCode).toBe(200);
        const body = JSON.parse(res.body);
        expect(body.text).toBe("Updated");
    });

    test("DELETE /todo/{id} should delete an existing todo", async () => {
        await handler(buildEvent("POST", "/todo", { text: "Delete me" }));
        const event = buildEvent("DELETE", "/todo/1");
        const res = await handler(event);
        expect(res.statusCode).toBe(204);
    });
});
