# frozen_string_literal: true

require './ports/dsl/datomic-flare'
require './components/errors'

RSpec.describe 'Flare Client', :client do
  it 'responds according to Client mode' do
    expect(@flare.meta['meta']['mode']).to eq('client')

    expect do
      @flare.api.get_database_names
    end.to raise_error(
      Flare::Errors::RequestError,
      /The get-database-names operation is not supported on Peer Servers/
    )

    expect do
      @flare.api.create_database!({ name: Flare.uuid.v7 })
    end.to raise_error(
      Flare::Errors::RequestError,
      /The create-database operation is not supported on Peer Servers/
    )

    expect do
      @flare.api.delete_database!({ name: Flare.uuid.v7 })
    end.to raise_error(
      Flare::Errors::RequestError,
      /The delete-database operation is not supported on Peer Servers/
    )

    expect do
      @flare.api.entity(
        { database: { latest: true }, id: 17_592_186_045_430 }
      )
    end.to raise_error(
      Flare::Errors::RequestError,
      /The entity operation is not supported on Peer Servers/
    )
  end
end
