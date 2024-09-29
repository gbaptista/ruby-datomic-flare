# frozen_string_literal: true

module Flare
  module H
    def self.symbolize_keys(structure)
      result = {}

      structure.each do |key, value|
        string_key = key.to_sym

        result[string_key] = value.is_a?(Hash) ? symbolize_keys(value) : value
      end

      result
    end
  end
end
