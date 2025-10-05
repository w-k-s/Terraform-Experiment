let todos = [];
let currentId = 1;

module.exports.handler = async (event) => {
    const method = event.requestContext.http.method;
    const path = event.requestContext.http.path;

    try {
        if (method === "GET" && path === "/todo") {
            return response(200, todos);
        }

        if (method === "POST" && path === "/todo") {
            const body = JSON.parse(event.body || "{}");
            if (!body.text) {
                return response(400, { message: "Missing text" });
            }
            const todo = { id: currentId++, text: body.text, completed: false };
            todos.push(todo);
            return response(201, todo);
        }

        if (method === "PATCH" && path.match(/^\/todo\/\d+$/)) {
            const id = path.split("/").pop();
            const body = JSON.parse(event.body || "{}");
            const todo = todos.find((t) => t.id === parseInt(id));
            if (!todo) return response(404, { message: "Todo not found" });
            if (body.text !== undefined) todo.text = body.text;
            if (body.completed !== undefined) todo.completed = body.completed;
            return response(200, todo);
        }

        if (method === "DELETE" && path.match(/^\/todo\/\d+$/)) {
            const id = path.split("/").pop();
            const index = todos.findIndex((t) => t.id === parseInt(id));
            if (index === -1) return response(404, { message: "Todo not found" });
            todos.splice(index, 1);
            return response(204, null);
        }

        return response(404, { message: "Not found" });
    } catch (err) {
        console.error(err);
        return response(500, { message: "Internal server error" });
    }
};

const response = (statusCode, body) => ({
    statusCode,
    body: body ? JSON.stringify(body) : undefined,
});

module.exports._reset = () => {
    todos = [];
    currentId = 1;
};