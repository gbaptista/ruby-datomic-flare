# frozen_string_literal: true

require_relative '../../logic/schema'
require_relative '../../logic/types'

module Flare
  module DSLSchema
    def transact_schema!(specification, database: nil, debug: nil)
      data = SchemaLogic.specification_to_edn(specification)

      payload = { data: }

      payload[:connection] = { database: { name: database } } unless database.nil?

      response = client.api.transact!(payload, debug:)

      debug ? response : true
    end

    def schema(database: nil, debug: nil)
      database_input = { latest: true }

      database_input[:name] = database unless database.nil?

      payload = {
        inputs: [{ database: database_input }],
        query: SchemaLogic::QUERY
      }

      response = client.api.q(payload, debug:)

      return response if debug

      SchemaLogic.datoms_to_specification(response['data'])
    end
  end
end
