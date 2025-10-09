const AWS = require("aws-sdk");
const Knex = require("knex");

const TABLE_NAME = "todos";

let knexInstance;


async function getKnex() {
    if (knexInstance) return knexInstance;

    const secretsManager = new AWS.SecretsManager();
    const secretName = process.env.AWS_SECRETSMANAGER_SECRET_NAME;

    if (!secretName) {
        throw new Error("Missing AWS_SECRETSMANAGER_SECRET_NAME");
    }

    const secretValue = await secretsManager
        .getSecretValue({ SecretId: secretName })
        .promise();

    const secret = JSON.parse(secretValue.SecretString || "{}");
    const connectionString = secret.db_conn_string;

    if (!connectionString) {
        throw new Error("Missing db_conn_string in secret");
    }

    knexInstance = Knex({
        client: "pg",
        connection: connectionString,
        pool: { min: 0, max: 5 },
    });

    return knexInstance;
}

module.exports.handler = async (event) => {

    console.log("Received event:", JSON.stringify(event, null, 2));

    const method = event.requestContext.http.method;
    const path = event.requestContext.http.path;
    const knex = await getKnex();

    try {
        if (method === "GET" && path === "/todo") {
            const todos = await knex(TABLE_NAME).select("*").orderBy("id");
            return response(200, todos);
        }

        if (method === "POST" && path === "/todo") {
            const body = JSON.parse(event.body || "{}");
            if (!body.text) {
                return response(400, { message: "Missing text" });
            }

            const [todo] = await knex(TABLE_NAME)
                .insert({ text: body.text, completed: false })
                .returning("*");

            return response(201, todo);
        }

        if (method === "PATCH" && path.match(/^\/todo\/\d+$/)) {
            const id = parseInt(path.split("/").pop());
            const body = JSON.parse(event.body || "{}");

            const updated = await knex(TABLE_NAME)
                .where({ id })
                .update({
                    ...(body.text !== undefined && { text: body.text }),
                    ...(body.completed !== undefined && { completed: body.completed }),
                })
                .returning("*");

            if (updated.length === 0) {
                return response(404, { message: "Todo not found" });
            }

            return response(200, updated[0]);
        }

        if (method === "DELETE" && path.match(/^\/todo\/\d+$/)) {
            const id = parseInt(path.split("/").pop());
            const deleted = await knex(TABLE_NAME).where({ id }).del();
            if (deleted === 0) {
                return response(404, { message: "Todo not found" });
            }
            return response(204, null);
        }

        return response(404, { message: "Not found" });
    } catch (err) {
        console.log("Error:", err);
        return response(500, { message: "Internal server error" });
    }
};

const response = (statusCode, body) => ({
    statusCode,
    headers: {
        "Content-Type": "application/json"
    },
    body: body ? JSON.stringify(body) : undefined,
});

module.exports._reset = async () => {
    const knex = await getKnex();
    await knex(TABLE_NAME).truncate();
};
