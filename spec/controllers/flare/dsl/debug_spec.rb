# frozen_string_literal: true

require './controllers/client'
require './logic/schema'

RSpec.describe Flare::Controllers::Client do
  let(:flare) { described_class.new(credentials: { address: '://' }) }

  describe 'when we have an instantiated client' do
    it 'has all the expected methods' do
      expect(
        flare.dsl.class.ancestors.take_while do |ancestor|
          ancestor != Object
        end.flat_map do |klass|
          klass.instance_methods(false)
        end.filter do |method_name|
          !%i[client client= api].include?(method_name)
        end.sort
      ).to eq(
        %i[create_database!
           destroy_database!
           databases
           transact_schema!
           schema
           assert_into!
           retract_from!
           query
           find_by_entity_id].sort
      )
    end
  end

  describe 'when debug keyword is provided' do
    it 'returns the payload of the request' do
      expect(
        flare.dsl.create_database!('supernova', debug: true)
      ).to eq(
        { method: 'POST',
          url: '://datomic/create-database',
          body: { 'name' => 'supernova' } }
      )

      expect(
        flare.dsl.destroy_database!('supernova', debug: true)
      ).to eq(
        { method: 'DELETE',
          url: '://datomic/delete-database',
          body: { 'name' => 'supernova' } }
      )

      expect(
        flare.dsl.databases(mode: 'peer', debug: true)
      ).to eq(
        {
          method: 'GET',
          url: '://datomic/get-database-names'
        }
      )

      expect(
        flare.dsl.databases(mode: 'server', debug: true)
      ).to eq(
        {
          method: 'GET',
          url: '://datomic/list-databases'
        }
      )

      expect(
        flare.dsl.transact_schema!(
          { post: { title: { type: :string } } },
          debug: true
        )
      ).to eq(
        { method: 'POST',
          url: '://datomic/transact',
          body: {
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
            'inputs' => [{ 'database' => { 'latest' => true } }],
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
          debug: true
        )
      ).to eq(
        { method: 'POST',
          url: '://datomic/transact',
          body: {
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
          debug: true
        )
      ).to eq(
        { method: 'POST',
          url: '://datomic/transact',
          body: {
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
          debug: true
        )
      ).to eq(
        { method: 'POST',
          url: '://datomic/transact',
          body: {
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
          debug: true
        )
      ).to eq(
        {
          method: 'POST',
          url: '://datomic/transact',
          body: {
            'data' => <<~EDN.strip
              [[:db/retract 17592186045429 :post/title "Hello World"]]
            EDN
          }
        }
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
            'data' => <<~EDN.strip
              [[:db/retract 17592186045429 :post/title]]
            EDN
          }
        }
      )

      expect(
        flare.dsl.retract_from!(
          :post, { _id: 17_592_186_045_429 },
          debug: true
        )
      ).to eq(
        {
          method: 'POST',
          url: '://datomic/transact',
          body: {
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
          debug: true
        )
      ).to eq(
        {
          method: 'POST',
          url: '://datomic/transact',
          body: {
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
            'inputs' => [{ 'database' => { 'latest' => true } }],
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
              { 'database' => { 'latest' => true } },
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
        flare.dsl.find_by_entity_id(17_592_186_045_430, debug: true)
      ).to eq(
        { method: 'GET',
          url: '://datomic/entity',
          body: {
            'database' => { 'latest' => true },
            'id' => 17_592_186_045_430
          } }
      )
    end
  end
end
