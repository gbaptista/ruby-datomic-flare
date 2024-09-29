# frozen_string_literal: true

require_relative '../../logic/querying'

module Flare
  module DSLQuerying
    def find_by_entity_id(id, database: nil, debug: nil)
      database_input = { latest: true }

      database_input[:name] = database unless database.nil?

      response = client.api.entity(
        { database: database_input, id: }, debug:
      )

      return response if debug

      QueryingLogic.entity_to_dsl(response['data'])
    end

    def query(datalog:, params: nil, database: nil, debug: nil)
      database_input = { latest: true }

      database_input[:name] = database unless database.nil?

      inputs = [{ database: database_input }]

      unless params.nil?
        raise "Unexpected params: [#{params.class}] #{params.inspect}" unless params.is_a?(Array)

        inputs.concat(params)
      end

      response = client.api.q({ inputs:, query: datalog.strip }, debug:)

      debug ? response : response['data']
    end
  end
end
