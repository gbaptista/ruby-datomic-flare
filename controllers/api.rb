# frozen_string_literal: true

module Flare
  class API
    attr_reader :client

    def initialize(client)
      @client = client
    end

    def create_database!(payload, debug: nil)
      client.request('datomic/create-database', payload, debug:)
    end

    def delete_database!(payload, debug: nil)
      client.request(
        'datomic/delete-database', payload,
        request_method: 'DELETE', debug:
      )
    end

    def transact!(payload, debug: nil)
      client.request('datomic/transact', payload, debug:)
    end

    def entity(payload, debug: nil)
      client.request('datomic/entity', payload, request_method: 'GET', debug:)
    end

    def datoms(payload, debug: nil)
      client.request('datomic/datoms', payload, request_method: 'GET', debug:)
    end

    def get_database_names(debug: nil)
      client.request(
        'datomic/get-database-names', request_method: 'GET', debug:
      )
    end

    def list_databases(debug: nil)
      client.request('datomic/list-databases', request_method: 'GET', debug:)
    end

    def q(payload, debug: nil)
      client.request('datomic/q', payload, request_method: 'GET', debug:)
    end
  end
end
