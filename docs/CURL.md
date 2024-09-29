# Datomic Flare

A web server that offers an HTTP/JSON API for interacting with [Datomic](https://www.datomic.com) databases.

![The image features a logo with curved lines forming a tesseract, suggesting distortion and movement like space-time.](https://media.githubusercontent.com/media/gbaptista/assets/refs/heads/main/datomic-flare/datomic-flare-canvas.png)

_This is not an official Datomic project or documentation and it is not affiliated with Datomic in any way._

## TL;DR and Quick Start

Ensure you have [Java](https://clojure.org/guides/install_clojure#java) and [Clojure](https://clojure.org/guides/install_clojure) installed.

```bash
cp .env.example .env

```

```bash
clj -M:run

```

```text
[main] INFO flare.components.server - Starting server on http://0.0.0.0:3042 as peer

```

Ensure you have [curl](https://github.com/curl/curl), [bb](https://github.com/babashka/babashka), and [jq](https://github.com/jqlang/jq) installed.

Transact a Schema:


```bash
echo '
[{:db/ident       :book/title
  :db/valueType   :db.type/string
  :db/cardinality :db.cardinality/one
  :db/doc         "The title of the book."}

 {:db/ident       :book/genre
  :db/valueType   :db.type/string
  :db/cardinality :db.cardinality/one
  :db/doc         "The genre of the book."}]
' \
| bb -e '(pr-str (edn/read-string (slurp *in*)))' \
| curl -s http://localhost:3042/datomic/transact \
  -X POST \
  -H "Content-Type: application/json" \
  --data-binary @- <<JSON \
| jq
{
  "data": $(cat)
}
JSON
```

Assert Facts:


```bash
echo '
[{:db/id      -1
  :book/title "The Tell-Tale Heart"
  :book/genre "Horror"}]
' \
| bb -e '(pr-str (edn/read-string (slurp *in*)))' \
| curl -s http://localhost:3042/datomic/transact \
  -X POST \
  -H "Content-Type: application/json" \
  --data-binary @- <<JSON \
| jq
{
  "data": $(cat)
}
JSON
```

Read the Data by Querying:


```bash
echo '
[:find ?e ?title ?genre
 :where [?e :book/title ?title]
        [?e :book/genre ?genre]]
' \
| bb -e '(pr-str (edn/read-string (slurp *in*)))' \
| curl -s http://localhost:3042/datomic/q \
  -X GET \
  -H "Content-Type: application/json" \
  --data-binary @- <<JSON \
| jq
{
  "inputs": [
    {
      "database": {
        "latest": true
      }
    }
  ],
  "query": $(cat)
}
JSON
```

```json
{
  "data": [
    [
      4611681620380877802,
      "The Tell-Tale Heart",
      "Horror"
    ]
  ]
}
```


- [TL;DR and Quick Start](#tldr-and-quick-start)
- [Running](#running)
- [Quick Start](#quick-start)
  - [CURL](#curl)
  - [Ruby](#ruby)
  - [JavaScript](#javascript)
  - [Python](#python)
- [Usage](#usage)
  - [Meta](#meta)
  - [Creating a Database](#creating-a-database)
  - [Deleting a Database](#deleting-a-database)
  - [Listing Databases](#listing-databases)
  - [Transacting Schema](#transacting-schema)
  - [Asserting Facts](#asserting-facts)
  - [Reading Data by Entity](#reading-data-by-entity)
  - [Reading Data by Querying](#reading-data-by-querying)
  - [Accumulating Facts](#accumulating-facts)
  - [Retracting Facts](#retracting-facts)
- [About](#about)
  - [Characteristics](#characteristics)
  - [Trade-offs](#trade-offs)
- [Development](#development)

## Running

The server can operate in _Client Mode_, using `com.datomic/client-pro` to connect to a Datomic Peer Server, or in _Peer Mode_, embedding `com.datomic/peer` to establish a _Peer_ directly within the server.

Copy the `.env.example` file and fill it with the appropriate information.

```bash
cp .env.example .env

```

If you want _Client Mode_:
```bash
FLARE_PORT=3042
FLARE_BIND=0.0.0.0

FLARE_MODE=client

FLARE_CLIENT_ENDPOINT=localhost:8998
FLARE_CLIENT_SECRET=unsafe-secret
FLARE_CLIENT_ACCESS_KEY=unsafe-key
FLARE_CLIENT_DATABASE_NAME=my-datomic-database

```

If you want _Peer Mode_:
```bash
FLARE_PORT=3042
FLARE_BIND=0.0.0.0

FLARE_MODE=peer

FLARE_PEER_CONNECTION_URI="datomic:sql://my-datomic-database?jdbc:postgresql://localhost:5432/my-datomic-storage?user=datomic-user&password=unsafe"

```

Ensure you have [Java](https://clojure.org/guides/install_clojure#java) and [Clojure](https://clojure.org/guides/install_clojure) installed.

Run the server:

```bash
clj -M:run

```

```text
[main] INFO flare.components.server - Starting server on http://0.0.0.0:3042 as peer

```

You should be able to start firing requests to the server:


```bash
curl -s http://localhost:3042/meta \
  -X GET \
  -H "Content-Type: application/json"  \
| jq
```

```json
{
  "data": {
    "datomic-flare": "1.0.0",
    "org.clojure/clojure": "1.12.0",
    "com.datomic/peer": "1.0.7187",
    "com.datomic/client-pro": "1.0.81"
  }
}
```

## Quick Start

### CURL
TODO

### Ruby
TODO

### JavaScript
TODO

### Python
TODO

## Usage

Ensure you have [curl](https://github.com/curl/curl), [bb](https://github.com/babashka/babashka), and [jq](https://github.com/jqlang/jq) installed.

### Meta


```bash
curl -s http://localhost:3042/meta \
  -X GET \
  -H "Content-Type: application/json"  \
| jq
```

```json
{
  "data": {
    "datomic-flare": "1.0.0",
    "org.clojure/clojure": "1.12.0",
    "com.datomic/peer": "1.0.7187",
    "com.datomic/client-pro": "1.0.81"
  }
}
```

### Creating a Database


```bash
curl -s http://localhost:3042/datomic/create-database \
  -X POST \
  -H "Content-Type: application/json" \
  -d '
{
  "name": "moonlight"
}
' \
| jq
```

```json
{
  "data": true
}
```

### Deleting a Database


```bash
curl -s http://localhost:3042/datomic/delete-database \
  -X DELETE \
  -H "Content-Type: application/json" \
  -d '
{
  "name": "moonlight"
}
' \
| jq
```

```json
{
  "data": true
}
```

### Listing Databases

Flare on Peer Mode:
```bash
curl -s http://localhost:3042/datomic/get-database-names \
  -X GET \
  -H "Content-Type: application/json"  \
| jq

```

Flare on Client Mode
```bash
curl -s http://localhost:3042/datomic/list-databases \
  -X GET \
  -H "Content-Type: application/json"  \
| jq

```

```json
{
  "data": [
    "my-datomic-database"
  ]
}

```

### Transacting Schema


```bash
echo '
[{:db/ident       :book/title
  :db/valueType   :db.type/string
  :db/cardinality :db.cardinality/one
  :db/doc         "The title of the book."}

 {:db/ident       :book/genre
  :db/valueType   :db.type/string
  :db/cardinality :db.cardinality/one
  :db/doc         "The genre of the book."}

 {:db/ident       :book/published_at_year
  :db/valueType   :db.type/long
  :db/cardinality :db.cardinality/one
  :db/doc         "The year the book was first published."}]
' \
| bb -e '(pr-str (edn/read-string (slurp *in*)))' \
| curl -s http://localhost:3042/datomic/transact \
  -X POST \
  -H "Content-Type: application/json" \
  --data-binary @- <<JSON \
| jq
{
  "data": $(cat)
}
JSON
```

```json
{
  "data": {
    "db-before": "datomic.db.Db@1cf55f93",
    "db-after": "datomic.db.Db@1bdd0be0",
    "tx-data": [
      [1003, 50, "Sun Sep 22 08:58:31 BRT 2024", 1003, true],
      [74, 10, "published_at_year", 1003, true],
      [74, 40, 22, 1003, true],
      [74, 41, 35, 1003, true],
      [74, 62, "The year the book was first published.", 1003, true],
      [0, 13, 74, 1003, true]
    ],
    "tempids": {
      "-9223300668110593560": 72,
      "-9223300668110593559": 73,
      "-9223300668110593558": 74
    }
  }
}
```

### Asserting Facts


```bash
echo '
[{:db/id      -1
  :book/title "Pride and Prejudice"
  :book/genre "Romance"
  :book/published_at_year 1813}]
' \
| bb -e '(pr-str (edn/read-string (slurp *in*)))' \
| curl -s http://localhost:3042/datomic/transact \
  -X POST \
  -H "Content-Type: application/json" \
  --data-binary @- <<JSON \
| jq
{
  "data": $(cat)
}
JSON
```

```json
{
  "data": {
    "db-before": "datomic.db.Db@39bb3c53",
    "db-after": "datomic.db.Db@d8d15290",
    "tx-data": [
      [1004, 50, "Sun Sep 22 08:58:31 BRT 2024", 1004, true],
      [1005, 72, "Pride and Prejudice", 1004, true],
      [1005, 73, "Romance", 1004, true],
      [1005, 74, 1813, 1004, true]
    ],
    "tempids": {
      "-1": 4611681620380877805
    }
  }
}
```



```bash
echo '
[{:db/id      -1
  :book/title "Near to the Wild Heart"
  :book/genre "Novel"
  :book/published_at_year 1943}
 {:db/id      -2
  :book/title "A Study in Scarlet"
  :book/genre "Detective"
  :book/published_at_year 1887}
 {:db/id      -3
  :book/title "The Tell-Tale Heart"
  :book/genre "Horror"
  :book/published_at_year 1843}]
' \
| bb -e '(pr-str (edn/read-string (slurp *in*)))' \
| curl -s http://localhost:3042/datomic/transact \
  -X POST \
  -H "Content-Type: application/json" \
  --data-binary @- <<JSON \
| jq
{
  "data": $(cat)
}
JSON
```

```json
{
  "data": {
    "db-before": "datomic.db.Db@d8d15290",
    "db-after": "datomic.db.Db@19234447",
    "tx-data": [
      [1006, 50, "Sun Sep 22 08:58:31 BRT 2024", 1006, true],
      [1007, 72, "Near to the Wild Heart", 1006, true],
      [1007, 73, "Novel", 1006, true],
      [1007, 74, 1943, 1006, true],
      [1008, 72, "A Study in Scarlet", 1006, true],
      [1008, 73, "Detective", 1006, true],
      [1008, 74, 1887, 1006, true],
      [1009, 72, "The Tell-Tale Heart", 1006, true],
      [1009, 73, "Horror", 1006, true],
      [1009, 74, 1843, 1006, true]
    ],
    "tempids": {
      "-1": 4611681620380877807,
      "-2": 4611681620380877808,
      "-3": 4611681620380877809
    }
  }
}
```

### Reading Data by Entity


```bash
curl -s http://localhost:3042/datomic/entity \
  -X GET \
  -H "Content-Type: application/json" \
  -d '
{
  "database": {
    "latest": true
  },
  "id": 4611681620380877807
}
' \
| jq
```

```json
{
  "data": {
    ":book/title": "Near to the Wild Heart",
    ":book/genre": "Novel",
    ":book/published_at_year": 1943,
    ":db/id": 4611681620380877807
  }
}
```

### Reading Data by Querying


```bash
echo '
[:find ?e ?title ?genre ?year
 :where [?e :book/title ?title]
        [?e :book/genre ?genre]
        [?e :book/published_at_year ?year]]
' \
| bb -e '(pr-str (edn/read-string (slurp *in*)))' \
| curl -s http://localhost:3042/datomic/q \
  -X GET \
  -H "Content-Type: application/json" \
  --data-binary @- <<JSON \
| jq
{
  "inputs": [
    {
      "database": {
        "latest": true
      }
    }
  ],
  "query": $(cat)
}
JSON
```

```json
{
  "data": [
    [
      4611681620380877808,
      "A Study in Scarlet",
      "Detective",
      1887
    ],
    [
      4611681620380877807,
      "Near to the Wild Heart",
      "Novel",
      1943
    ],
    [
      4611681620380877809,
      "The Tell-Tale Heart",
      "Horror",
      1843
    ],
    [
      4611681620380877805,
      "Pride and Prejudice",
      "Romance",
      1813
    ]
  ]
}
```


```bash
echo '
[:find ?e ?title ?genre ?year
 :in $ ?title
 :where [?e :book/title ?title]
        [?e :book/genre ?genre]
        [?e :book/published_at_year ?year]]
' \
| bb -e '(pr-str (edn/read-string (slurp *in*)))' \
| curl -s http://localhost:3042/datomic/q \
  -X GET \
  -H "Content-Type: application/json" \
  --data-binary @- <<JSON \
| jq
{
  "inputs": [
    {
      "database": {
        "latest": true
      }
    },
    "The Tell-Tale Heart"
  ],
  "query": $(cat)
}
JSON
```

```json
{
  "data": [
    [
      4611681620380877809,
      "The Tell-Tale Heart",
      "Horror",
      1843
    ]
  ]
}
```

### Accumulating Facts


```bash
echo '
[{:db/id 4611681620380877806 :book/genre "Gothic"}]
' \
| bb -e '(pr-str (edn/read-string (slurp *in*)))' \
| curl -s http://localhost:3042/datomic/transact \
  -X POST \
  -H "Content-Type: application/json" \
  --data-binary @- <<JSON \
| jq
{
  "data": $(cat)
}
JSON
```

```json
{
  "data": {
    "db-before": "datomic.db.Db@19234447",
    "db-after": "datomic.db.Db@6f78a7c",
    "tx-data": [
      [1010, 50, "Sun Sep 22 08:58:31 BRT 2024", 1010, true],
      [1006, 73, "Gothic", 1010, true]
    ],
    "tempids": {
    }
  }
}
```

### Retracting Facts

Retract the value of an attribute:


```bash
echo '
[[:db/retract 4611681620380877806 :book/genre "Gothic"]]
' \
| bb -e '(pr-str (edn/read-string (slurp *in*)))' \
| curl -s http://localhost:3042/datomic/transact \
  -X POST \
  -H "Content-Type: application/json" \
  --data-binary @- <<JSON \
| jq
{
  "data": $(cat)
}
JSON
```

```json
{
  "data": {
    "db-before": "datomic.db.Db@6f78a7c",
    "db-after": "datomic.db.Db@89bedc15",
    "tx-data": [
      [1011, 50, "Sun Sep 22 08:58:31 BRT 2024", 1011, true],
      [1006, 73, "Gothic", 1011, false]
    ],
    "tempids": {
    }
  }
}
```

Retract an attribute:


```bash
echo '
[[:db/retract 4611681620380877804 :book/genre]]
' \
| bb -e '(pr-str (edn/read-string (slurp *in*)))' \
| curl -s http://localhost:3042/datomic/transact \
  -X POST \
  -H "Content-Type: application/json" \
  --data-binary @- <<JSON \
| jq
{
  "data": $(cat)
}
JSON
```

```json
{
  "data": {
    "db-before": "datomic.db.Db@89bedc15",
    "db-after": "datomic.db.Db@4fa1fea2",
    "tx-data": [
      [1012, 50, "Sun Sep 22 08:58:31 BRT 2024", 1012, true]
    ],
    "tempids": {
    }
  }
}
```

Retract an entity:


```bash
echo '
[[:db/retractEntity 4611681620380877805]]
' \
| bb -e '(pr-str (edn/read-string (slurp *in*)))' \
| curl -s http://localhost:3042/datomic/transact \
  -X POST \
  -H "Content-Type: application/json" \
  --data-binary @- <<JSON \
| jq
{
  "data": $(cat)
}
JSON
```

```json
{
  "data": {
    "db-before": "datomic.db.Db@4fa1fea2",
    "db-after": "datomic.db.Db@74650f2d",
    "tx-data": [
      [1013, 50, "Sun Sep 22 08:58:31 BRT 2024", 1013, true],
      [1005, 72, "Pride and Prejudice", 1013, false],
      [1005, 73, "Romance", 1013, false],
      [1005, 74, 1813, 1013, false]
    ],
    "tempids": {
    }
  }
}
```

## About

### Characteristics

- Languages that play well with HTTP and JSON can interact with Datomic right away.

- Plug and play into any of the many flavors of Datomic's flexible infrastructure architecture.

- Minimal and transparent layer, not a DSL or framework, just straightforward access to Datomic.

- Despite JSON, both queries and transactions are done in EDN, enabling, e.g., powerful Datalog queries.

### Trade-offs

- Languages have different data types, so EDN -> JSON -> [Your Language] and vice-versa: something will be lost in translation and expressiveness.

- An extra layer in the architecture adds a new hop to requests, potentially increasing latency.

- Being one step away from Clojure reduces our power to leverage its types, data structures, immutability, and other desired properties.

- Some tricks that would be easy to do in Clojure + Datomic become more cumbersome: transaction functions, advanced Datalog datasources, lazy loading, etc.

## Development

```bash
clj -M:repl

```

```bash
clj -M:format
clj -M:lint

```

```bash
cljfmt fix deps.edn src/
clj-kondo --lint deps.edn src/

```
