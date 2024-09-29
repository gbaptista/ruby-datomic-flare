# frozen_string_literal: true

require './controllers/client'
require './logic/schema'

RSpec.describe Flare::Controllers::Client do
  let(:flare) do
    described_class.new(
      credentials: { address: '://' },
      dangerously_override: {
        database: { name: 'purple', as_of: 13_194_139_534_323 }
      }
    )
  end

  describe 'when the debug keyword is provided' do
    it 'returns the payload of the request' do
      expect(
        flare.dsl.transact_schema!(
          { post: { title: { type: :string } } },
          debug: true
        )
      ).to eq(
        { method: 'POST',
          url: '://datomic/transact',
          body: {
            'connection' => { 'database' => { 'name' => 'purple' } },
            'data' => <<~EDN.strip
              [{:db/ident       :post/title
                :db/valueType   :db.type/string
                :db/cardinality :db.cardinality/one}]
            EDN
          } }
      )

      expect(
        flare.dsl.schema(debug: true)
      ).to eq(
        { method: 'GET',
          url: '://datomic/q',
          body: {
            'inputs' => [
              { 'database' => {
                'name' => 'purple', 'as_of' => 13_194_139_534_323
              } }
            ],
            'query' => Flare::SchemaLogic::QUERY
          } }
      )

      expect(
        flare.dsl.assert_into!(
          :post,
          { title: 'Hello World' },
          debug: true
        )
      ).to eq(
        { method: 'POST',
          url: '://datomic/transact',
          body: {
            'connection' => { 'database' => { 'name' => 'purple' } },
            'data' => <<~EDN.strip
              [{:post/title "Hello World"
                :db/id -1}]
            EDN
          } }
      )

      expect(
        flare.dsl.retract_from!(
          :post, { _id: 17_592_186_045_429, title: nil },
          debug: true
        )
      ).to eq(
        {
          method: 'POST',
          url: '://datomic/transact',
          body: {
            'connection' => { 'database' => { 'name' => 'purple' } },
            'data' => <<~EDN.strip
              [[:db/retract 17592186045429 :post/title]]
            EDN
          }
        }
      )

      expect(
        flare.dsl.query(
          debug: true,
          datalog: <<~EDN
            [:find ?e ?title ?year ?genre
             :where [?e :movie/title ?title]
                    [?e :movie/release_year ?year]
                    [?e :movie/genre ?genre]]
          EDN
        )
      ).to eq(
        { method: 'GET',
          url: '://datomic/q',
          body: {
            'inputs' => [
              { 'database' => {
                'name' => 'purple', 'as_of' => 13_194_139_534_323
              } }
            ],
            'query' => <<~EDN.strip
              [:find ?e ?title ?year ?genre
               :where [?e :movie/title ?title]
                      [?e :movie/release_year ?year]
                      [?e :movie/genre ?genre]]
            EDN
          } }
      )

      expect(
        flare.dsl.query(
          debug: true,
          params: ['Commando'],
          datalog: <<~EDN
            [:find ?e ?title ?year ?genre
             :in $ ?title
             :where [?e :movie/title ?title]
                    [?e :movie/release_year ?year]
                    [?e :movie/genre ?genre]]
          EDN
        )
      ).to eq(
        { method: 'GET',
          url: '://datomic/q',
          body: {
            'inputs' => [
              { 'database' => {
                'name' => 'purple', 'as_of' => 13_194_139_534_323
              } },
              'Commando'
            ],
            'query' => <<~EDN.strip
              [:find ?e ?title ?year ?genre
               :in $ ?title
               :where [?e :movie/title ?title]
                      [?e :movie/release_year ?year]
                      [?e :movie/genre ?genre]]
            EDN
          } }
      )

      expect(
        flare.dsl.find_by_entity_id(
          17_592_186_045_430,
          debug: true
        )
      ).to eq(
        { method: 'GET',
          url: '://datomic/entity',
          body: {
            'database' => {
              'name' => 'purple', 'as_of' => 13_194_139_534_323
            },
            'id' => 17_592_186_045_430
          } }
      )
    end
  end

  describe 'when the debug keyword and a database name are provided' do
    it 'returns the payload of the request' do
      expect(
        flare.dsl.transact_schema!(
          { post: { title: { type: :string } } },
          database: 'red',
          debug: true
        )
      ).to eq(
        { method: 'POST',
          url: '://datomic/transact',
          body: {
            'connection' => { 'database' => { 'name' => 'purple' } },
            'data' => <<~EDN.strip
              [{:db/ident       :post/title
                :db/valueType   :db.type/string
                :db/cardinality :db.cardinality/one}]
            EDN
          } }
      )

      expect(
        flare.dsl.schema(database: 'red', debug: true)
      ).to eq(
        { method: 'GET',
          url: '://datomic/q',
          body: {
            'inputs' => [
              { 'database' => {
                'name' => 'purple', 'as_of' => 13_194_139_534_323
              } }
            ],
            'query' => Flare::SchemaLogic::QUERY
          } }
      )

      expect(
        flare.dsl.assert_into!(
          :post,
          { title: 'Hello World' },
          database: 'red',
          debug: true
        )
      ).to eq(
        { method: 'POST',
          url: '://datomic/transact',
          body: {
            'connection' => { 'database' => { 'name' => 'purple' } },
            'data' => <<~EDN.strip
              [{:post/title "Hello World"
                :db/id -1}]
            EDN
          } }
      )

      expect(
        flare.dsl.assert_into!(
          :post,
          [{ title: 'Hello World' },
           { title: 'Spring Update' }],
          database: 'red',
          debug: true
        )
      ).to eq(
        { method: 'POST',
          url: '://datomic/transact',
          body: {
            'connection' => { 'database' => { 'name' => 'purple' } },
            'data' => <<~EDN.strip
              [{:post/title "Hello World"
                :db/id -1}
               {:post/title "Spring Update"
                :db/id -2}]
            EDN
          } }
      )

      expect(
        flare.dsl.assert_into!(
          :post,
          { _id: 17_592_186_045_429, title: 'Hello World' },
          database: 'red',
          debug: true
        )
      ).to eq(
        { method: 'POST',
          url: '://datomic/transact',
          body: {
            'connection' => { 'database' => { 'name' => 'purple' } },
            'data' => <<~EDN.strip
              [{:db/id 17592186045429
                :post/title "Hello World"}]
            EDN
          } }
      )

      expect(
        flare.dsl.assert_into!(
          :post,
          [{ _id: 17_592_186_045_429, title: 'Hello World' },
           { _id: 17_592_186_045_430, title: 'Spring Update' }],
          database: 'red',
          debug: true
        )
      ).to eq(
        { method: 'POST',
          url: '://datomic/transact',
          body: {
            'connection' => { 'database' => { 'name' => 'purple' } },
            'data' => <<~EDN.strip
              [{:db/id 17592186045429
                :post/title "Hello World"}
               {:db/id 17592186045430
                :post/title "Spring Update"}]
            EDN
          } }
      )

      expect(
        flare.dsl.retract_from!(
          :post, { _id: 17_592_186_045_429, title: 'Hello World' },
          database: 'red',
          debug: true
        )
      ).to eq(
        {
          method: 'POST',
          url: '://datomic/transact',
          body: {
            'connection' => { 'database' => { 'name' => 'purple' } },
            'data' => <<~EDN.strip
              [[:db/retract 17592186045429 :post/title "Hello World"]]
            EDN
          }
        }
      )

      expect(
        flare.dsl.retract_from!(
          :post, { _id: 17_592_186_045_429, title: nil },
          database: 'red',
          debug: true
        )
      ).to eq(
        {
          method: 'POST',
          url: '://datomic/transact',
          body: {
            'connection' => { 'database' => { 'name' => 'purple' } },
            'data' => <<~EDN.strip
              [[:db/retract 17592186045429 :post/title]]
            EDN
          }
        }
      )

      expect(
        flare.dsl.retract_from!(
          :post, { _id: 17_592_186_045_429 },
          database: 'red',
          debug: true
        )
      ).to eq(
        {
          method: 'POST',
          url: '://datomic/transact',
          body: {
            'connection' => { 'database' => { 'name' => 'purple' } },
            'data' => <<~EDN.strip
              [[:db/retractEntity 17592186045429]]
            EDN
          }
        }
      )

      expect(
        flare.dsl.retract_from!(
          :post,
          [{ _id: 17_592_186_045_429 },
           { _id: 17_592_186_045_430 }],
          database: 'red',
          debug: true
        )
      ).to eq(
        {
          method: 'POST',
          url: '://datomic/transact',
          body: {
            'connection' => { 'database' => { 'name' => 'purple' } },
            'data' => <<~EDN.strip
              [[:db/retractEntity 17592186045429]
               [:db/retractEntity 17592186045430]]
            EDN
          }
        }
      )

      expect(
        flare.dsl.query(
          debug: true,
          database: 'red',
          datalog: <<~EDN
            [:find ?e ?title ?year ?genre
             :where [?e :movie/title ?title]
                    [?e :movie/release_year ?year]
                    [?e :movie/genre ?genre]]
          EDN
        )
      ).to eq(
        { method: 'GET',
          url: '://datomic/q',
          body: {
            'inputs' => [
              { 'database' => {
                'name' => 'purple', 'as_of' => 13_194_139_534_323
              } }
            ],
            'query' => <<~EDN.strip
              [:find ?e ?title ?year ?genre
               :where [?e :movie/title ?title]
                      [?e :movie/release_year ?year]
                      [?e :movie/genre ?genre]]
            EDN
          } }
      )

      expect(
        flare.dsl.query(
          debug: true,
          database: 'red',
          params: ['Commando'],
          datalog: <<~EDN
            [:find ?e ?title ?year ?genre
             :in $ ?title
             :where [?e :movie/title ?title]
                    [?e :movie/release_year ?year]
                    [?e :movie/genre ?genre]]
          EDN
        )
      ).to eq(
        { method: 'GET',
          url: '://datomic/q',
          body: {
            'inputs' => [
              { 'database' => {
                'name' => 'purple', 'as_of' => 13_194_139_534_323
              } },
              'Commando'
            ],
            'query' => <<~EDN.strip
              [:find ?e ?title ?year ?genre
               :in $ ?title
               :where [?e :movie/title ?title]
                      [?e :movie/release_year ?year]
                      [?e :movie/genre ?genre]]
            EDN
          } }
      )

      expect(
        flare.dsl.find_by_entity_id(
          17_592_186_045_430,
          database: 'red',
          debug: true
        )
      ).to eq(
        { method: 'GET',
          url: '://datomic/entity',
          body: {
            'database' => {
              'name' => 'purple', 'as_of' => 13_194_139_534_323
            },
            'id' => 17_592_186_045_430
          } }
      )
    end
  end
end
