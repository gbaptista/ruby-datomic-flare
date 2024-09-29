# Datomic Flare for Ruby

A Ruby gem for interacting with [Datomic](https://www.datomic.com) through [Datomic Flare](https://github.com/gbaptista/datomic-flare).

![The image features a logo with curved lines forming a ruby, suggesting distortion and movement like space-time.](https://media.githubusercontent.com/media/gbaptista/assets/refs/heads/main/ruby-datomic-flare/ruby-datomic-flare-canvas.png)

_This is not an official Datomic project or documentation and it is not affiliated with Datomic in any way._

## TL;DR and Quick Start

```ruby
gem 'datomic-flare', '~> 1.0.1'
```

```ruby
require 'datomic-flare'

client = Flare.new(credentials: { address: 'http://localhost:3042' })
```

```ruby
client.dsl.transact_schema!(
  {
    book: {
      title: { type: :string, doc: 'The title of the book.' },
      genre: { type: :string, doc: 'The genre of the book.' }
    }
  }
)

client.dsl.assert_into!(
  :book,
  {
    title: 'The Tell-Tale Heart',
    genre: 'Horror'
  }
)

client.dsl.query(
  datalog: <<~EDN
    [:find ?e ?title ?genre
     :where [?e :book/title ?title]
            [?e :book/genre ?genre]]
  EDN
)
```

```ruby
[[4611681620380877802, 'The Tell-Tale Heart', 'Horror']]
```

- [TL;DR and Quick Start](#tldr-and-quick-start)
- [Flare](#flare)
  - [Creating a Client](#creating-a-client)
  - [Meta](#meta)
- [Flare DSL](#flare-dsl)
  - [Creating a Database](#creating-a-database)
  - [Deleting a Database](#deleting-a-database)
  - [Listing Databases](#listing-databases)
  - [Transacting Schema](#transacting-schema)
  - [Checking Schema](#checking-schema)
  - [Asserting Facts](#asserting-facts)
  - [Reading Data by Entity](#reading-data-by-entity)
  - [Reading Data by Querying](#reading-data-by-querying)
  - [Accumulating Facts](#accumulating-facts)
  - [Retracting Facts](#retracting-facts)
- [Flare API](#flare-api)
  - [Creating a Database](#creating-a-database-1)
  - [Deleting a Database](#deleting-a-database-1)
  - [Listing Databases](#listing-databases-1)
  - [Transacting Schema](#transacting-schema-1)
  - [Checking Schema](#checking-schema-1)
  - [Asserting Facts](#asserting-facts-1)
  - [Reading Data by Entity](#reading-data-by-entity-1)
  - [Reading Data by Querying](#reading-data-by-querying-1)
  - [Accumulating Facts](#accumulating-facts-1)
  - [Retracting Facts](#retracting-facts-1)
- [Development](#development)
  - [Publish to RubyGems](#publish-to-rubygems)
  - [Setup for Tests and Documentation](#setup-for-tests-and-documentation)
  - [Running Tests](#running-tests)
  - [Updating the README](#updating-the-readme)

## Flare

### Creating a Client

```ruby
require 'datomic-flare'

client = Flare.new(credentials: { address: 'http://localhost:3042' })
```

### Meta

```ruby
client.meta
```

```ruby
{
  'meta' =>
    {
      'at' => '2024-09-29T14:09:06.891354452Z',
      'mode' => 'peer',
      'took' => { 'milliseconds' => 0.439342 }
    },
  'data' =>
  {
    'mode' => 'peer',
    'datomic-flare' => '1.0.0',
    'org.clojure/clojure' => '1.12.0',
    'com.datomic/peer' => '1.0.7187',
    'com.datomic/client-pro' => '1.0.81'
  }
}
```

## Flare DSL

It provides a Ruby-familiar approach to working with Datomic. It brings Ruby’s conventions and idioms while preserving Datomic’s data-first principles and terminology.

This approach should be cozy to those who are familiar with Ruby.

Learn more about Ruby and The Rails Doctrine:

- [About Ruby](https://www.ruby-lang.org/en/about/)
- [The Rails Doctrine](https://rubyonrails.org/doctrine)

### Creating a Database

```ruby
client.dsl.create_database!('radioactive')
```

```ruby
true
```

### Deleting a Database

```ruby
client.dsl.destroy_database!('radioactive')
```

```ruby
true
```

### Listing Databases

```ruby
client.dsl.databases
```

```ruby
['my-datomic-database']
```

### Transacting Schema

Like `CREATE TABLE` in SQL databases or defining document or record structures in other databases.

```ruby
client.dsl.transact_schema!(
  {
    book: {
      title: { type: :string, doc: 'The title of the book.' },
      genre: { type: :string, doc: 'The genre of the book.' },
      published_at_year: { type: :long, doc: 'The year the book was first published.' }
    }
  }
)
```

```ruby
true
```

### Checking Schema

Like `SHOW COLUMNS FROM` in SQL databases or checking document or record structures in other databases.

```ruby
client.dsl.schema
```

```ruby
{
  book: {
    published_at_year: {
      type: :long,
      cardinality: :one,
      doc: 'The year the book was first published.',
      unique: false,
      index: false,
      history: true
    },
    title: {
      type: :string,
      cardinality: :one,
      doc: 'The title of the book.',
      unique: false,
      index: false,
      history: true
    },
    genre: {
      type: :string,
      cardinality: :one,
      doc: 'The genre of the book.',
      unique: false,
      index: false,
      history: true
    }
  }
}
```

### Asserting Facts

Like `INSERT INTO` in SQL databases or creating a new document or record in other databases.

```ruby
client.dsl.assert_into!(
  :book,
  {
    title: 'Pride and Prejudice',
    genre: 'Romance',
    published_at_year: 1813
  }
)
```

```ruby
4611681620380877802
```

```ruby
client.dsl.assert_into!(
  :book,
  [{
    title: 'Near to the Wild Heart',
    genre: 'Novel',
    published_at_year: 1943
  },
   {
     title: 'A Study in Scarlet',
     genre: 'Detective',
     published_at_year: 1887
   },
   {
     title: 'The Tell-Tale Heart',
     genre: 'Horror',
     published_at_year: 1843
   }]
)
```


```ruby
[4611681620380877804, 4611681620380877805, 4611681620380877806]
```

### Reading Data by Entity

Like `SELECT` in SQL databases or querying documents or records in other databases.

```ruby
client.dsl.find_by_entity_id(4611681620380877804)
```

```ruby
{
  book: {
    title: 'Near to the Wild Heart',
    genre: 'Novel',
    published_at_year: 1943,
    _id: 4611681620380877804
  }
}
```

### Reading Data by Querying

Like `SELECT` in SQL databases or querying documents or records in other databases.

```ruby
client.dsl.query(
  datalog: <<~EDN
    [:find ?e ?title ?genre ?year
     :where [?e :book/title ?title]
            [?e :book/genre ?genre]
            [?e :book/published_at_year ?year]]
  EDN
)
```

```ruby
[[4611681620380877805, 'A Study in Scarlet', 'Detective', 1887],
 [4611681620380877804, 'Near to the Wild Heart', 'Novel', 1943],
 [4611681620380877806, 'The Tell-Tale Heart', 'Horror', 1843],
 [4611681620380877802, 'Pride and Prejudice', 'Romance', 1813]]
```

```ruby
client.dsl.query(
  params: ['The Tell-Tale Heart'],
  datalog: <<~EDN
    [:find ?e ?title ?genre ?year
     :in $ ?title
     :where [?e :book/title ?title]
            [?e :book/genre ?genre]
            [?e :book/published_at_year ?year]]
  EDN
)
```


```ruby
[[4611681620380877806, 'The Tell-Tale Heart', 'Horror', 1843]]
```

### Accumulating Facts

Like `UPDATE` in SQL databases or updating documents or records in other databases. However, Datomic never updates data. It is an immutable database that only accumulates new facts or retracts past facts.

```ruby
client.dsl.assert_into!(
  :book, { _id: 4611681620380877806, genre: 'Gothic' }
)
```

```ruby
4611681620380877806
```

### Retracting Facts

Like `DELETE` in SQL databases or deleting documents or records in other databases. However, Datomic never deletes data. It is an immutable database that only accumulates new facts or retracts past facts.

Retract the value of an attribute:

```ruby
client.dsl.retract_from!(
  :book, { _id: 4611681620380877806, genre: 'Gothic' }
)
```

```ruby
true
```

Retract an attribute:

```ruby
client.dsl.retract_from!(
  :book, { _id: 4611681620380877804, genre: nil }
)
```

```ruby
true
```

Retract an entity:

```ruby
client.dsl.retract_from!(
  :book, { _id: 4611681620380877805 }
)
```

```ruby
true
```


## Flare API

It provides methods that mirror [Datomic's APIs](https://docs.datomic.com/clojure/index.html). Most interactions use EDN, closely following [Datomic’s documentation](https://docs.datomic.com).

This approach should be familiar to those who know Datomic concepts and APIs.

Learn more about Clojure and Datomic:

- [Clojure Rationale](https://clojure.org/about/rationale)
- [Datomic Introduction](https://docs.datomic.com/datomic-overview.html)

### Creating a Database

```ruby
client.api.create_database!({ name: 'fireball' })['data']
```

```ruby
true
```

### Deleting a Database

```ruby
client.api.delete_database!({ name: 'fireball' })['data']
```

```ruby
true
```

### Listing Databases

```ruby
# Flare on Peer Mode
client.api.get_database_names['data']

# Flare on Client Mode
client.api.list_databases['data']
```

```ruby
['my-datomic-database']
```

### Transacting Schema

```ruby
client.api.transact!(
  { data: <<~EDN
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
  EDN
  }
)['data']
```

```ruby
{
  'db-before' => 'datomic.db.Db@7740573a',
  'db-after' => 'datomic.db.Db@7898935d',
  'tx-data' =>
  [[13194139534312, 50, '2024-09-29T14:09:07.059Z', 13194139534312, true],
   [72, 10, ':book/title', 13194139534312, true],
   [72, 40, 23, 13194139534312, true],
   [72, 41, 35, 13194139534312, true],
   [72, 62, 'The title of the book.', 13194139534312, true],
   [73, 10, ':book/genre', 13194139534312, true],
   [73, 40, 23, 13194139534312, true],
   [73, 41, 35, 13194139534312, true],
   [73, 62, 'The genre of the book.', 13194139534312, true],
   [74, 10, ':book/published_at_year', 13194139534312, true],
   [74, 40, 22, 13194139534312, true],
   [74, 41, 35, 13194139534312, true],
   [74, 62, 'The year the book was first published.', 13194139534312, true],
   [0, 13, 72, 13194139534312, true],
   [0, 13, 73, 13194139534312, true],
   [0, 13, 74, 13194139534312, true]],
  'tempids' =>
  {
    '-9223300668110558605' => 72,
    '-9223300668110558604' => 73,
    '-9223300668110558603' => 74
  }
}
```

### Checking Schema

```ruby
client.api.q(
  {
    inputs: [{ database: { latest: true } }],
    query: <<~EDN
      [:find
          ?e ?ident ?value_type ?cardinality ?doc
          ?unique ?index ?no_history
       :in $
       :where
         [?e :db/ident ?ident]

         [?e :db/valueType ?value_type_id]
         [?value_type_id :db/ident ?value_type]

         [?e :db/cardinality ?cardinality_id]
         [?cardinality_id :db/ident ?cardinality]

         [(get-else $ ?e :db/doc "") ?doc]

         [(get-else $ ?e :db/unique -1) ?unique_id]
         [(get-else $ ?unique_id :db/ident false) ?unique]

         [(get-else $ ?e :db/index false) ?index]
         [(get-else $ ?e :db/noHistory false) ?no_history]]
    EDN
  }
)['data'].filter do |datom|
  !%w[
    db
    db.alter db.attr db.bootstrap db.cardinality db.entity db.excise
    db.fn db.install db.lang db.part db.sys db.type db.unique
    fressian
  ].include?(datom[1].split('/').first)
end
```

```ruby
[[74,
  'book/published_at_year',
  'db.type/long',
  'db.cardinality/one',
  'The year the book was first published.',
  false,
  false,
  false],
 [72,
  'book/title',
  'db.type/string',
  'db.cardinality/one',
  'The title of the book.',
  false,
  false,
  false],
 [73,
  'book/genre',
  'db.type/string',
  'db.cardinality/one',
  'The genre of the book.',
  false,
  false,
  false]]
```

### Asserting Facts

```ruby
client.api.transact!(
  { data: <<~EDN
    [{:db/id      -1
      :book/title "Pride and Prejudice"
      :book/genre "Romance"
      :book/published_at_year 1813}]
  EDN
  }
)['data']
```

```ruby
{
  'db-before' => 'datomic.db.Db@4f9110f1',
  'db-after' => 'datomic.db.Db@1b8a609c',
  'tx-data' =>
  [[13194139534313, 50, '2024-09-29T14:09:07.167Z', 13194139534313, true],
   [4611681620380877802, 72, 'Pride and Prejudice', 13194139534313, true],
   [4611681620380877802, 73, 'Romance', 13194139534313, true],
   [4611681620380877802, 74, 1813, 13194139534313, true]],
  'tempids' => { '-1' => 4611681620380877802 }
}
```

```ruby
client.api.transact!(
  { data: <<~EDN
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
  EDN
  }
)['data']
```


```ruby
{
  'db-before' => 'datomic.db.Db@6e061d50',
  'db-after' => 'datomic.db.Db@523869b6',
  'tx-data' =>
  [[13194139534315, 50, '2024-09-29T14:09:07.207Z', 13194139534315, true],
   [4611681620380877804, 72, 'Near to the Wild Heart', 13194139534315, true],
   [4611681620380877804, 73, 'Novel', 13194139534315, true],
   [4611681620380877804, 74, 1943, 13194139534315, true],
   [4611681620380877805, 72, 'A Study in Scarlet', 13194139534315, true],
   [4611681620380877805, 73, 'Detective', 13194139534315, true],
   [4611681620380877805, 74, 1887, 13194139534315, true],
   [4611681620380877806, 72, 'The Tell-Tale Heart', 13194139534315, true],
   [4611681620380877806, 73, 'Horror', 13194139534315, true],
   [4611681620380877806, 74, 1843, 13194139534315, true]],
  'tempids' =>
  {
    '-1' => 4611681620380877804,
    '-2' => 4611681620380877805,
    '-3' => 4611681620380877806
  }
}
```

### Reading Data by Entity

```ruby
client.api.entity(
  {
    database: { latest: true },
    id: 4611681620380877804
  }
)['data']
```

```ruby
{
  ':book/title' => 'Near to the Wild Heart',
  ':book/genre' => 'Novel',
  ':book/published_at_year' => 1943,
  ':db/id' => 4611681620380877804
}
```

### Reading Data by Querying

```ruby
client.api.q(
  {
    inputs: [{ database: { latest: true } }],
    query: <<~EDN
      [:find ?e ?title ?genre ?year
       :where [?e :book/title ?title]
              [?e :book/genre ?genre]
              [?e :book/published_at_year ?year]]
    EDN
  }
)['data']
```

```ruby
[[4611681620380877805, 'A Study in Scarlet', 'Detective', 1887],
 [4611681620380877804, 'Near to the Wild Heart', 'Novel', 1943],
 [4611681620380877806, 'The Tell-Tale Heart', 'Horror', 1843],
 [4611681620380877802, 'Pride and Prejudice', 'Romance', 1813]]
```

```ruby
client.api.q(
  {
    inputs: [
      { database: { latest: true } },
      'The Tell-Tale Heart'
    ],
    query: <<~EDN
      [:find ?e ?title ?genre ?year
       :in $ ?title
       :where [?e :book/title ?title]
              [?e :book/genre ?genre]
              [?e :book/published_at_year ?year]]
    EDN
  }
)['data']
```


```ruby
[[4611681620380877806, 'The Tell-Tale Heart', 'Horror', 1843]]
```

### Accumulating Facts

```ruby
client.api.transact!(
  { data: <<~EDN
    [{:db/id 4611681620380877806 :book/genre "Gothic"}]
  EDN
  }
)['data']
```

```ruby
{
  'db-before' => 'datomic.db.Db@15e9ed98',
  'db-after' => 'datomic.db.Db@29007ec5',
  'tx-data' =>
  [[13194139534319, 50, '2024-09-29T14:09:07.420Z', 13194139534319, true],
   [4611681620380877806, 73, 'Gothic', 13194139534319, true],
   [4611681620380877806, 73, 'Horror', 13194139534319, false]],
  'tempids' => {}
}
```

### Retracting Facts

Retract the value of an attribute:

```ruby
client.api.transact!(
  { data: <<~EDN
    [[:db/retract 4611681620380877806 :book/genre "Gothic"]]
  EDN
  }
)['data']
```

```ruby
{
  'db-before' => 'datomic.db.Db@27c78595',
  'db-after' => 'datomic.db.Db@5d2ff139',
  'tx-data' =>
  [[13194139534320, 50, '2024-09-29T14:09:07.470Z', 13194139534320, true],
   [4611681620380877806, 73, 'Gothic', 13194139534320, false]],
  'tempids' => {}
}
```

Retract an attribute:

```ruby
client.api.transact!(
  { data: <<~EDN
    [[:db/retract 4611681620380877804 :book/genre]]
  EDN
  }
)['data']
```

```ruby
{
  'db-before' => 'datomic.db.Db@23f815b5',
  'db-after' => 'datomic.db.Db@39d9b51',
  'tx-data' =>
  [[13194139534321, 50, '2024-09-29T14:09:07.510Z', 13194139534321, true],
   [4611681620380877804, 73, 'Novel', 13194139534321, false]],
  'tempids' => {}
}
```

Retract an entity:

```ruby
client.api.transact!(
  { data: <<~EDN
    [[:db/retractEntity 4611681620380877805]]
  EDN
  }
)['data']
```

```ruby
{
  'db-before' => 'datomic.db.Db@66fa8fae',
  'db-after' => 'datomic.db.Db@60c2b7f2',
  'tx-data' =>
  [[13194139534322, 50, '2024-09-29T14:09:07.550Z', 13194139534322, true],
   [4611681620380877805, 72, 'A Study in Scarlet', 13194139534322, false],
   [4611681620380877805, 73, 'Detective', 13194139534322, false],
   [4611681620380877805, 74, 1887, 13194139534322, false]],
  'tempids' => {}
}
```


## Development

```bash
bundle
rubocop -A

```

### Publish to RubyGems

```bash
gem build datomic-flare.gemspec

gem signin

gem push datomic-flare-1.0.1.gem

```

### Setup for Tests and Documentation

Tests run against real Datomic databases, and documentation (README) is generated by interacting with real Datomic databases.

To accomplish that, we need to have [Datomic](https://github.com/gbaptista/datomic-pro-docker) and [Flare](https://github.com/gbaptista/datomic-flare) running.

**TL;DR:**

```bash
git clone https://github.com/gbaptista/datomic-pro-docker.git

cd datomic-pro-docker

cp compose/flare-dev.yml docker-compose.yml

docker compose up -d datomic-storage

docker compose run datomic-tools psql \
  -f bin/sql/postgres-table.sql \
  -h datomic-storage \
  -U datomic-user \
  -d my-datomic-storage

docker compose up -d datomic-transactor

docker compose run datomic-tools clojure -M -e "$(cat <<'CLOJURE'
  (require '[datomic.api :as d])
  
  (d/create-database "datomic:sql://my-datomic-database?jdbc:postgresql://datomic-storage:5432/my-datomic-storage?user=datomic-user&password=unsafe")

  (d/create-database "datomic:sql://my-datomic-database-test?jdbc:postgresql://datomic-storage:5432/my-datomic-storage?user=datomic-user&password=unsafe")

  (d/create-database "datomic:sql://my-datomic-database-test-green?jdbc:postgresql://datomic-storage:5432/my-datomic-storage?user=datomic-user&password=unsafe")

  (System/exit 0)
CLOJURE
)"

docker compose up -d datomic-peer-server

docker compose up -d datomic-flare-peer datomic-flare-client

```

```bash
curl -s http://localhost:3042/meta \
  -X GET \
  -H "Content-Type: application/json"  \
| jq

```

```json
{
  "data": {
    "mode": "peer"
  }
}

```

```bash
curl -s http://localhost:3043/meta \
  -X GET \
  -H "Content-Type: application/json"  \
| jq

```

```json
{
  "data": {
    "mode": "client"
  }
}

```

You are ready to run tests and generate documentation.

**Detailed instructions:**

Clone the [datomic-pro-docker](https://github.com/gbaptista/datomic-pro-docker) repository and copy the Docker Compose template:

```bash
git clone https://github.com/gbaptista/datomic-pro-docker.git

cd datomic-pro-docker

cp compose/flare-dev.yml docker-compose.yml

```

Start PostgreSQL as Datomic's storage service:

```bash
docker compose up -d datomic-storage

docker compose logs -f datomic-storage

```

Create the table for Datomic databases:

```bash
docker compose run datomic-tools psql \
  -f bin/sql/postgres-table.sql \
  -h datomic-storage \
  -U datomic-user \
  -d my-datomic-storage

```

You will be prompted for a password, which is `unsafe`.

Start the Datomic Transactor:

```bash
docker compose up -d datomic-transactor

docker compose logs -f datomic-transactor

```

Create the following databases:

- `my-datomic-database`
- `my-datomic-database-test`
- `my-datomic-database-test-green`

```bash
docker compose run datomic-tools clojure -M -e "$(cat <<'CLOJURE'
  (require '[datomic.api :as d])
  
  (d/create-database "datomic:sql://my-datomic-database?jdbc:postgresql://datomic-storage:5432/my-datomic-storage?user=datomic-user&password=unsafe")

  (d/create-database "datomic:sql://my-datomic-database-test?jdbc:postgresql://datomic-storage:5432/my-datomic-storage?user=datomic-user&password=unsafe")

  (d/create-database "datomic:sql://my-datomic-database-test-green?jdbc:postgresql://datomic-storage:5432/my-datomic-storage?user=datomic-user&password=unsafe")

  (System/exit 0)
CLOJURE
)"

```

Start the Peer Server:

```bash
docker compose up -d datomic-peer-server

docker compose logs -f datomic-peer-server

```

Start 2 instances of Flare, one in Peer Mode and another in Client Mode:

```bash
docker compose up -d datomic-flare-peer datomic-flare-client

docker compose logs -f datomic-flare-peer
docker compose logs -f datomic-flare-client

```

You should be able to request both:

Datomic Flare in Peer Mode:
```bash
curl -s http://localhost:3042/meta \
  -X GET \
  -H "Content-Type: application/json"  \
| jq

```

```json
{
  "data": {
    "mode": "peer"
  }
}

```

Datomic Flare in Client Mode:
```bash
curl -s http://localhost:3043/meta \
  -X GET \
  -H "Content-Type: application/json"  \
| jq

```

```json
{
  "data": {
    "mode": "client"
  }
}

```

You are ready to run tests and generate documentation.

### Running Tests

Tests run against real Datomic databases, so complete the [Setup for Tests and Documentation](#setup-for-tests-and-documentation) first.

```bash
cp .env.example .env

bundle exec rspec

```

### Updating the README

Documentation (README) is generated by interacting with real Datomic databases, so complete the [Setup for Tests and Documentation](#setup-for-tests-and-documentation) first.

Update the `docs/templates/*.md` files, and then:

```sh
cp .env.example .env

bundle exec ruby ports/cli.rb docs:generate

```

Trick for automatically updating the `README.md` when `docs/templates/*.md` files change:

```sh
sudo pacman -S inotify-tools # Arch / Manjaro
sudo apt-get install inotify-tools # Debian / Ubuntu / Raspberry Pi OS
sudo dnf install inotify-tools # Fedora / CentOS / RHEL

while inotifywait -e modify docs/templates/*; \
  do bundle exec ruby ports/cli.rb docs:generate; \
  done

```

Trick for Markdown Live Preview:
```sh
pip install -U markdown_live_preview

mlp README.md -p 8042 --no-follow

```
