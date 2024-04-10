# oasis

OASIS: OpenAPI SWIFT Internal Server

```bash
swift package init --name oasis --type executable
```

See the package code

Run the server and test with curl.

```bash
Server starting on http://127.0.0.1:8080
```

```bash
% curl 'http://localhost:8080/api/greet?name=Jane'
{
  "message" : "Hello, Jane!"
}
```

```bash
curl http://localhost:8080/api/emoji
curl http://127.0.0.1:8080/api/emoji
"👋"
```
