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

  describe 'when debug keyword is provided' do
    it 'returns the payload of the request' do
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
            'connection' => { 'database' => { 'name' => 'purple' } },
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
              { 'database' => {
                'name' => 'purple', 'as_of' => 13_194_139_534_323
              } },
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
            'database' => { 'name' => 'purple', 'as_of' => 13_194_139_534_323 },
            'id' => 17_592_186_045_430
          } }
      )
    end
  end
end
