app [Model, init!, respond!] { pf: platform "https://github.com/roc-lang/basic-webserver/releases/download/0.12.0/Q4h_In-sz1BqAvlpmCsBHhEJnn_YvfRRMiNACB_fBbk.tar.br",
json: "https://github.com/lukewilliamboswell/roc-json/releases/download/0.12.0/1trwx8sltQ-e9Y2rOB4LWUWLS_sFVyETK8Twl0i9qpw.tar.gz"}

import pf.Stdout
import pf.Http exposing [Request, Response]
import pf.Utc
import json.Json
import pf.Sqlite
import pf.Env

# Model is produced by `init`.
Model : { foo: Str, stmt: Sqlite.Stmt }

# With `init` you can set up a database connection once at server startup,
# generate css by running `tailwindcss`,...
# Here we open the DB and prepare a statement.
init! : {} => Result Model [ServerErr Str]_
init! = \{} ->
    db_path = Env.var! "DB_PATH" ? \_ -> ServerErr "DB_PATH not set on environment"

    stmt =
        Sqlite.prepare!(
            {
                path: db_path,
                query: "SELECT id, task, status FROM todos WHERE status = :status;",
            },
        )
        ? \err -> ServerErr "Failed to prepare Sqlite statement: $(Inspect.to_str err)"

    Ok { foo: "woo", stmt }

respond! : Request, Model => Result Response [ServerErr Str]_
respond! = \req, mod ->
    # Log request datetime, method and url
    datetime = Utc.to_iso_8601 (Utc.now! {})

    try Stdout.line! "model: $(mod.foo) $(datetime) $(Inspect.to_str req.method) $(req.uri)"

    when req.uri is
        "/decode" ->
            # Attempt to decode JSON from the request body
            decoder = Json.utf8

            decoded : DecodeResult Payload
            decoded = Decode.from_bytes_partial(req.body, decoder)

            when decoded.result is
                Ok(payload) ->
                    Ok {
                        status: 200,
                        headers: [
                            { name: "Content-Type", value: "application/json" }
                        ],
                        body: Encode.to_bytes(payload, Json.utf8),
                    }

                Err(err) ->
                    Ok {
                        status: 400,
                        headers: [ { name: "Content-Type", value: "text/plain; charset=utf-8" } ],
                        body: Str.to_utf8 "Failed to decode JSON: $(Inspect.to_str err)",
                    }

        "/decode-example" ->
            # Decode a hardcoded JSON example to demonstrate usage
            example_json = Str.to_utf8 "{\"message\":\"hello\",\"count\":42}"
            decoder = Json.utf8

            decoded_example : DecodeResult Payload
            decoded_example = Decode.from_bytes_partial(example_json, decoder)

            when decoded_example.result is
                Ok(payload) -> Ok {
                    status: 200,
                    headers: [ { name: "Content-Type", value: "application/json" } ],
                    body: Encode.to_bytes(payload, Json.utf8),
                }
                Err(err) -> Ok {
                    status: 500,
                    headers: [ { name: "Content-Type", value: "text/plain; charset=utf-8" } ],
                    body: Str.to_utf8 "Example decode failed: $(Inspect.to_str err)",
                }

        "/todos" ->
            rows =
                Sqlite.query_many_prepared!(
                    {
                        stmt: mod.stmt,
                        bindings: [ { name: ":status", value: String("todo") } ],
                        rows: { Sqlite.decode_record <-
                            id: Sqlite.i64("id"),
                            task: Sqlite.str("task"),
                            status: Sqlite.str("status"),
                        },
                    },
                )?
                |> List.map \r -> { id: r.id, task: r.task, status: r.status }

            Ok {
                status: 200,
                headers: [ { name: "Content-Type", value: "application/json" } ],
                body: Encode.to_bytes(rows, Json.utf8),
            }

        _ ->
            Ok {
                status: 200,
                headers: [],
                body: Str.to_utf8 "<b>Hello from server</b> $(datetime)</br>",
            }

# Simple payload we decode from JSON
Payload : { message : Str, count : I64 }
