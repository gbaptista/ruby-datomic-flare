# frozen_string_literal: true

module Flare
  module QueryingLogic
    def self.entity_to_dsl(entity)
      namespace = entity.keys.find { |key| key != ':db/id' }

      return nil if namespace.nil?

      namespace = namespace.split('/').first.sub(/^:/, '').to_sym

      {
        namespace => keys_to_dsl(entity)
      }
    end

    def self.keys_to_dsl(entity)
      result = {}

      entity.each do |key, value|
        # TODO: Is this correct? Should the 'id' exist?
        dsl_key = if [':db/id', 'id'].include?(key)
                    :_id
                  else
                    key.split('/').last.to_sym
                  end

        result[dsl_key] = value.is_a?(Hash) ? keys_to_dsl(value) : value
      end

      result
    end
  end
end
