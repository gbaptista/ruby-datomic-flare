# frozen_string_literal: true

module Flare
  module DangerousOverrideLogic
    CONNECTION_DATABASE_KEYS = [:name].freeze

    DATABASE_KEYS = %i[name latest as_of].freeze

    def self.apply_dangerous_overrides_to_payload(path, overrides, payload)
      case path
      when 'datomic/create-database', 'datomic/delete-database',
           'datomic/get-database-names', 'datomic/list-databases',
           'meta',
           'datomic/_debug/as-peer/create-database',
           'datomic/_debug/as-peer/delete-database'
        payload
      when 'datomic/transact'
        inject_connection_overrides(overrides, payload)
      when 'datomic/entity', 'datomic/datoms'
        inject_database_overrides(overrides, payload)
      when 'datomic/q'
        inject_database_overrides_into_inputs(overrides, payload)
      else
        raise "Unexpected path: '#{path}'"
      end
    end

    def self.inject_connection_overrides(overrides, payload)
      if !overrides.key?(:database) || overrides[:database].slice(
        *CONNECTION_DATABASE_KEYS
      ).empty?
        return payload
      end

      payload[:connection] = {} unless payload.key?(:connection)

      payload[:connection][:database] = {} unless payload[:connection].key?(:database)

      payload[:connection][:database] = payload[:connection][:database].merge(
        overrides[:database].slice(*CONNECTION_DATABASE_KEYS)
      )

      payload
    end

    def self.inject_overrides_into_input(overrides, input)
      input_has_latest = input[:database].key?(:latest)

      input_has_as_of = input[:database].key?(:as_of)

      overrides_has_as_of = overrides[:database].key?(:as_of)
      overrides_has_latest = overrides[:database].key?(:latest)

      input[:database] = input[:database].except(:latest) if input_has_latest && overrides_has_as_of

      input[:database] = input[:database].except(:as_of) if input_has_as_of && overrides_has_latest

      input[:database] = input[:database].merge(
        overrides[:database].slice(*DATABASE_KEYS)
      )

      input
    end

    def self.inject_database_overrides_into_inputs(overrides, payload)
      if !overrides.key?(:database) || overrides[:database].slice(
        *DATABASE_KEYS
      ).empty?
        return payload
      end

      payload[:inputs] = {} unless payload.key?(:inputs)

      index_for_database = payload[:inputs].index do |input|
        input.key?(:database)
      end

      if index_for_database.nil?
        require 'pry'
        binding.pry
      end

      payload[:inputs][index_for_database] = inject_overrides_into_input(
        overrides,
        payload[:inputs][index_for_database]
      )

      payload
    end

    def self.inject_database_overrides(overrides, payload)
      if !overrides.key?(:database) || overrides[:database].slice(
        *DATABASE_KEYS
      ).empty?
        return payload
      end

      payload[:database] = {} unless payload.key?(:database)

      payload[:database] = inject_overrides_into_input(
        overrides,
        { database: payload[:database] }
      )[:database]

      payload
    end
  end
end
