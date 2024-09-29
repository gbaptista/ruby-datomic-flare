# frozen_string_literal: true

require 'dotenv/load'

require './ports/dsl/datomic-flare'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.before(:each, :client) do
    @database_name = 'my-datomic-database-test'

    @flare = Flare.new(credentials: { address: ENV.fetch('FLARE_AS_CLIENT_ADDRESS') })

    @max_entity_id = @flare.api.datoms(
      { database: { latest: true, name: 'my-datomic-database-test-green' }, index: :eavt }
    )['data'].max { |datom| datom[0] }[0]
  end

  config.after(:each, :client) do
    max_entity_id = @flare.api.datoms(
      { database: { latest: true, name: @database_name }, index: :eavt }
    )['data'].max { |datom| datom[0] }[0]

    if max_entity_id > @max_entity_id
      entities_to_retract = @flare.api.datoms(
        { database: { latest: true }, index: :eavt }
      )['data'].map { |datom| datom[0] }
                                  .uniq
                                  .filter { |entity_id| entity_id > 66 }

      edn = entities_to_retract.map do |entity_id|
        "{:db/excise #{entity_id}}"
      end

      @flare.api.transact!(
        { data: "[#{edn.join("\n")}]" }
      )
    end
  end

  config.before(:each, :peer) do
    @database_name = "my-datomic-database-test-#{Flare.uuid.v7}"

    @flare = Flare.new(credentials: { address: ENV.fetch('FLARE_AS_PEER_ADDRESS') })

    @flare.dsl.create_database!(@database_name)
  end

  config.after(:each, :peer) do
    @flare.dsl.destroy_database!(@database_name)
  end
end
