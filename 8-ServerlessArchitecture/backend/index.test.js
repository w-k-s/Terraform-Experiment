const { handler, _reset } = require("./index.js");

describe("Todo API", () => {
    beforeEach(() => {
        _reset();
    });


    const buildEvent = (method, path, body = null) => ({
        requestContext: { http: { method, path } },
        body: body ? JSON.stringify(body) : null,
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
