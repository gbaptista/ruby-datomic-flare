# frozen_string_literal: true

require './controllers/client'
require './logic/schema'

RSpec.describe Flare::Controllers::Client do
  let(:flare) { described_class.new(credentials: { address: '://' }) }

  describe 'when we have an instantiated client' do
    it 'has all the expected methods' do
      expect(
        flare.api.class.instance_methods(false).filter do |method_name|
          !%i[client client=].include?(method_name)
        end.sort
      ).to eq(
        %i[create_database!
           delete_database!
           get_database_names
           list_databases
           transact!
           datoms
           q
           entity].sort
      )
    end
  end

  describe 'when debug keyword is provided' do
    it 'returns the payload of the request' do
      expect(
        flare.meta(debug: true)
      ).to eq(
        {
          method: 'GET',
          url: '://meta'
        }
      )

      expect(
        flare.api.create_database!(
          { name: 'supernova' }, debug: true
        )
      ).to eq(
        {
          method: 'POST',
          url: '://datomic/create-database',
          body: { 'name' => 'supernova' }
        }
      )

      expect(
        flare.api.delete_database!(
          { name: 'supernova' }, debug: true
        )
      ).to eq(
        {
          method: 'DELETE',
          url: '://datomic/delete-database',
          body: { 'name' => 'supernova' }
        }
      )

      expect(
        flare.api.get_database_names(debug: true)
      ).to eq(
        {
          method: 'GET',
          url: '://datomic/get-database-names'
        }
      )

      expect(
        flare.api.list_databases(debug: true)
      ).to eq(
        {
          method: 'GET',
          url: '://datomic/list-databases'
        }
      )

      expect(
        flare.api.transact!(
          { data: <<~EDN.strip
            [{:post/title "Hello World" :db/id -1}]
          EDN
          },
          debug: true
        )
      ).to eq(
        { method: 'POST',
          url: '://datomic/transact',
          body: {
            'data' => <<~EDN.strip
              [{:post/title "Hello World" :db/id -1}]
            EDN
          } }
      )

      expect(
        flare.api.q(
          { inputs: [
              { database: { latest: true } },
              'Commando'
            ],
            query: <<~EDN
              [:find ?e ?title ?year ?genre
               :in $ ?title
               :where [?e :movie/title ?title]
                      [?e :movie/release_year ?year]
                      [?e :movie/genre ?genre]]
            EDN
          },
          debug: true
        )
      ).to eq(
        { method: 'GET',
          url: '://datomic/q',
          body: {
            'inputs' => [
              { 'database' => { 'latest' => true } },
              'Commando'
            ],
            'query' => <<~EDN
              [:find ?e ?title ?year ?genre
               :in $ ?title
               :where [?e :movie/title ?title]
                      [?e :movie/release_year ?year]
                      [?e :movie/genre ?genre]]
            EDN
          } }
      )

      expect(
        flare.api.entity(
          { database: { latest: true },
            id: 17_592_186_045_430 },
          debug: true
        )
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
