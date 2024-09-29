## Flare API

It provides methods that mirror [Datomic's APIs](https://docs.datomic.com/clojure/index.html). Most interactions use EDN, closely following [Datomic’s documentation](https://docs.datomic.com).

This approach should be familiar to those who know Datomic concepts and APIs.

Learn more about Clojure and Datomic:

- [Clojure Rationale](https://clojure.org/about/rationale)
- [Datomic Introduction](https://docs.datomic.com/datomic-overview.html)

### Creating a Database

```ruby:runnable
client.api.create_database!({ name: 'fireball' })['data']
```

```ruby:placeholder
```

### Deleting a Database

```ruby:runnable
client.api.delete_database!({ name: 'fireball' })['data']
```

```ruby:placeholder
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

```ruby:runnable
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

```ruby:placeholder
```

### Checking Schema

```ruby:runnable
client.api.q(
  { inputs: [{ database: { latest: true } }],
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

```ruby:placeholder
```

### Asserting Facts

```ruby:runnable
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

```ruby:placeholder
```

```ruby:runnable
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

```ruby:state
state[:wild_heart_entity_id] = result['tempids']['-1']
state[:scarlet_entity_id] = result['tempids']['-2']
```

```ruby:placeholder
```

### Reading Data by Entity

```ruby:runnable/render
client.api.entity(
  { database: { latest: true },
    id: {{ state.wild_heart_entity_id }} }
)['data']
```

```ruby:placeholder
```

### Reading Data by Querying

```ruby:runnable
client.api.q(
  { inputs: [{ database: { latest: true } }],
    query: <<~EDN
      [:find ?e ?title ?genre ?year
       :where [?e :book/title ?title]
              [?e :book/genre ?genre]
              [?e :book/published_at_year ?year]]
    EDN
  }
)['data']
```

```ruby:placeholder
```

```ruby:runnable
client.api.q(
  { inputs: [
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

```ruby:state
state[:tale_heart_entity_id] = result[0][0]
```

```ruby:placeholder
```

### Accumulating Facts

```ruby:runnable/render
client.api.transact!(
  { data: <<~EDN
    [{:db/id {{ state.tale_heart_entity_id }} :book/genre "Gothic"}]
  EDN
  }
)['data']
```

```ruby:placeholder
```

### Retracting Facts

Retract the value of an attribute:

```ruby:runnable/render
client.api.transact!(
  { data: <<~EDN
    [[:db/retract {{ state.tale_heart_entity_id }} :book/genre "Gothic"]]
  EDN
  }
)['data']
```

```ruby:placeholder
```

Retract an attribute:

```ruby:runnable/render
client.api.transact!(
  { data: <<~EDN
    [[:db/retract {{ state.wild_heart_entity_id }} :book/genre]]
  EDN
  }
)['data']
```

```ruby:placeholder
```

Retract an entity:

```ruby:runnable/render
client.api.transact!(
  { data: <<~EDN
    [[:db/retractEntity {{ state.scarlet_entity_id }}]]
  EDN
  }
)['data']
```

```ruby:placeholder
```
