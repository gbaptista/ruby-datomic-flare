# frozen_string_literal: true

require './components/errors'

RSpec.describe 'Flare Client', :peer do
  it 'responds according to Peer mode' do
    expect(@flare.meta['meta']['mode']).to eq('peer')

    expect do
      @flare.api.list_databases
    end.to raise_error(
      Flare::Errors::RequestError,
      /The list-databases operation is not supported on Embedded Peers/
    )
  end
end
