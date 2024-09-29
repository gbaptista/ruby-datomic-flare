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
