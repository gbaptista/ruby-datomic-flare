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
  'db-before' => 'datomic.db.Db@7978603f',
  'db-after' => 'datomic.db.Db@359875e3',
  'tx-data' =>
  [[13194139534312, 50, '2024-10-06T13:17:38.945Z', 13194139534312, true],
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
    '-9223300668110597923' => 72,
    '-9223300668110597922' => 73,
    '-9223300668110597921' => 74
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
  'db-before' => 'datomic.db.Db@1fd69b02',
  'db-after' => 'datomic.db.Db@fb09bc2',
  'tx-data' =>
  [[13194139534313, 50, '2024-10-06T13:17:39.060Z', 13194139534313, true],
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
  'db-before' => 'datomic.db.Db@35f37b93',
  'db-after' => 'datomic.db.Db@43b227a3',
  'tx-data' =>
  [[13194139534315, 50, '2024-10-06T13:17:39.105Z', 13194139534315, true],
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
  'db-before' => 'datomic.db.Db@6817aa5c',
  'db-after' => 'datomic.db.Db@63f25217',
  'tx-data' =>
  [[13194139534319, 50, '2024-10-06T13:17:39.322Z', 13194139534319, true],
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
  'db-before' => 'datomic.db.Db@4d739219',
  'db-after' => 'datomic.db.Db@7f38a06d',
  'tx-data' =>
  [[13194139534320, 50, '2024-10-06T13:17:39.385Z', 13194139534320, true],
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
  'db-before' => 'datomic.db.Db@71ff51fa',
  'db-after' => 'datomic.db.Db@75c0cb1d',
  'tx-data' =>
  [[13194139534321, 50, '2024-10-06T13:17:39.428Z', 13194139534321, true],
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
  'db-before' => 'datomic.db.Db@30c25bc1',
  'db-after' => 'datomic.db.Db@a43be7c',
  'tx-data' =>
  [[13194139534322, 50, '2024-10-06T13:17:39.471Z', 13194139534322, true],
   [4611681620380877805, 72, 'A Study in Scarlet', 13194139534322, false],
   [4611681620380877805, 73, 'Detective', 13194139534322, false],
   [4611681620380877805, 74, 1887, 13194139534322, false]],
  'tempids' => {}
}
```
