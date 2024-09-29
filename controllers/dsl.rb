# frozen_string_literal: true

require_relative 'dsl/schema'
require_relative 'dsl/transacting'
require_relative 'dsl/querying'

module Flare
  class DSL
    include DSLQuerying
    include DSLSchema
    include DSLTransacting

    attr_reader :client, :api

    def initialize(client)
      @client = client
      @api = client.api
    end

    def create_database!(database_name, debug: nil)
      result = api.create_database!(
        { name: database_name }, debug:
      )

      debug ? result : result['data']
    end

    def destroy_database!(database_name, debug: nil)
      result = api.delete_database!(
        { name: database_name }, debug:
      )

      debug ? result : result['data']
    end

    def databases(mode:, debug: nil)
      mode = client.meta['meta']['mode'] if mode.nil?

      response = if mode == 'peer'
                   client.api.get_database_names(debug:)
                 else
                   client.api.list_databases(debug:)
                 end

      debug ? response : response['data']
    end
  end
end
