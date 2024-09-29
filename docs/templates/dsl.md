## Flare DSL

It provides a Ruby-familiar approach to working with Datomic. It brings Ruby’s conventions and idioms while preserving Datomic’s data-first principles and terminology.

This approach should be cozy to those who are familiar with Ruby.

Learn more about Ruby and The Rails Doctrine:

- [About Ruby](https://www.ruby-lang.org/en/about/)
- [The Rails Doctrine](https://rubyonrails.org/doctrine)

### Creating a Database

```ruby:runnable
client.dsl.create_database!('radioactive')
```

```ruby:placeholder
```

### Deleting a Database

```ruby:runnable
client.dsl.destroy_database!('radioactive')
```

```ruby:placeholder
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

```ruby:runnable
client.dsl.transact_schema!(
{
  book: {
    title: { type: :string, doc: 'The title of the book.' },
    genre: { type: :string, doc: 'The genre of the book.' },
    published_at_year: { type: :long, doc: 'The year the book was first published.' }
  }
})
```

```ruby:placeholder
```

### Checking Schema

Like `SHOW COLUMNS FROM` in SQL databases or checking document or record structures in other databases.

```ruby:runnable
client.dsl.schema
```

```ruby:placeholder

```

### Asserting Facts

Like `INSERT INTO` in SQL databases or creating a new document or record in other databases.

```ruby:runnable
client.dsl.assert_into!(
  :book,
  { title: 'Pride and Prejudice',
    genre: 'Romance',
    published_at_year: 1813 }
)
```

```ruby:placeholder
```

```ruby:runnable
client.dsl.assert_into!(
  :book,
  [{ title: 'Near to the Wild Heart',
     genre: 'Novel',
     published_at_year: 1943 },
   { title: 'A Study in Scarlet',
     genre: 'Detective',
     published_at_year: 1887 },
   { title: 'The Tell-Tale Heart',
     genre: 'Horror',
     published_at_year: 1843 }]
)
```

```ruby:state
state[:wild_heart_entity_id] = result[0]
state[:scarlet_entity_id] = result[1]
```

```ruby:placeholder
```

### Reading Data by Entity

Like `SELECT` in SQL databases or querying documents or records in other databases.

```ruby:runnable/render
client.dsl.find_by_entity_id({{ state.wild_heart_entity_id }})
```

```ruby:placeholder
```

### Reading Data by Querying

Like `SELECT` in SQL databases or querying documents or records in other databases.

```ruby:runnable
client.dsl.query(
  datalog: <<~EDN
    [:find ?e ?title ?genre ?year
     :where [?e :book/title ?title]
            [?e :book/genre ?genre]
            [?e :book/published_at_year ?year]]
  EDN
)
```

```ruby:placeholder
```

```ruby:runnable
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

```ruby:state
state[:tale_heart_entity_id] = result[0][0]
```

```ruby:placeholder
```

### Accumulating Facts

Like `UPDATE` in SQL databases or updating documents or records in other databases. However, Datomic never updates data. It is an immutable database that only accumulates new facts or retracts past facts.

```ruby:runnable/render
client.dsl.assert_into!(
  :book, { _id: {{ state.tale_heart_entity_id }}, genre: 'Gothic' }
)
```

```ruby:placeholder
```

### Retracting Facts

Like `DELETE` in SQL databases or deleting documents or records in other databases. However, Datomic never deletes data. It is an immutable database that only accumulates new facts or retracts past facts.

Retract the value of an attribute:

```ruby:runnable/render
client.dsl.retract_from!(
  :book, { _id: {{ state.tale_heart_entity_id }}, genre: 'Gothic' }
)
```

```ruby:placeholder
```

Retract an attribute:

```ruby:runnable/render
client.dsl.retract_from!(
  :book, { _id: {{ state.wild_heart_entity_id }}, genre: nil }
)
```

```ruby:placeholder
```

Retract an entity:

```ruby:runnable/render
client.dsl.retract_from!(
  :book, { _id: {{ state.scarlet_entity_id }} }
)
```

```ruby:placeholder
```
