# frozen_string_literal: true

require './controllers/client'
require './logic/schema'

RSpec.describe Flare::Controllers::Client do
  let(:flare) { described_class.new(credentials: { address: '://' }) }

  describe 'when the debug keyword and a database name are provided' do
    it 'returns the payload of the request' do
      expect(
        flare.dsl.transact_schema!(
          { post: { title: { type: :string } } },
          database: 'purple',
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
        flare.dsl.schema(database: 'purple', debug: true)
      ).to eq(
        { method: 'GET',
          url: '://datomic/q',
          body: {
            'inputs' => [{ 'database' => { 'latest' => true, 'name' => 'purple' } }],
            'query' => Flare::SchemaLogic::QUERY
          } }
      )

      expect(
        flare.dsl.assert_into!(
          :post,
          { title: 'Hello World' },
          database: 'purple',
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
          database: 'purple',
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
          database: 'purple',
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
          database: 'purple',
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
          database: 'purple',
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
          database: 'purple',
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
          database: 'purple',
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
          database: 'purple',
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
          database: 'purple',
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
              { 'database' => { 'latest' => true, 'name' => 'purple' } }
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
          database: 'purple',
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
              { 'database' => { 'latest' => true, 'name' => 'purple' } },
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
          database: 'purple',
          debug: true
        )
      ).to eq(
        { method: 'GET',
          url: '://datomic/entity',
          body: {
            'database' => { 'latest' => true, 'name' => 'purple' },
            'id' => 17_592_186_045_430
          } }
      )
    end
  end
end
