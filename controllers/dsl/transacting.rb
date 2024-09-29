# frozen_string_literal: true

require_relative '../../logic/transacting'
require_relative '../../logic/types'

module Flare
  module DSLTransacting
    def retract_from!(namespace, data, database: nil, debug: nil)
      transaction_data = data.is_a?(Array) ? data : [data]

      transaction_data = TransactingLogic.retractions_to_edn(
        namespace, transaction_data
      )

      payload = { data: transaction_data }

      payload[:connection] = { database: { name: database } } unless database.nil?

      response = client.api.transact!(payload, debug:)

      debug ? response : true
    end

    def assert_into!(namespace, data, database: nil, raw: nil, debug: nil)
      transaction_data = data.is_a?(Array) ? data : [data]

      ids = {}

      # Within the scope of a single transaction, tempids map consistently
      # to permanent ids. Values of n from -1 to -1000000, inclusive, are
      # reserved for user-created tempids.
      transaction_data = transaction_data.map.with_index do |fact, i|
        if fact.key?(:_id)
          ids[fact[:_id]] = fact[:_id]
          fact
        else
          temporary_id = (i + 1) * -1
          ids[temporary_id] = nil
          fact.merge({ _temporary_id: temporary_id })
        end
      end

      transaction_data = TransactingLogic.transactions_to_edn(
        namespace, transaction_data
      )

      payload = { data: transaction_data }

      payload[:connection] = { database: { name: database } } unless database.nil?

      result = client.api.transact!(payload, debug:)

      return result if debug || raw

      result['data']['tempids'].map do |temporary_id, entity_id|
        ids[temporary_id.to_i] = entity_id
      end

      data.is_a?(Array) ? ids.values : ids.values.first
    end
  end
end
