# frozen_string_literal: true

require 'uri'
require 'bigdecimal'

module Flare
  module TypesLogic
    def self.to_datomic_value(value)
      case value
      when String
        to_datomic_string(value)
      when Integer
        value.to_s
      when Float
        value.to_s
      when BigDecimal
        # https://github.com/relevance/edn-ruby/blob/master/lib/edn/core_ext.rb#L25
        "#{value.to_s('F')}M"
      when Integer, Float, TrueClass, FalseClass
        value.to_s
      when Time, DateTime, Date
        to_datomic_instant(value)
      when Symbol
        ":#{value}"
      when Array
        '[' + value.map { |v| to_datomic_value(v) }.join(' ') + ']'
      when NilClass
        'nil'
      when Hash
        raise ArgumentError, "Missing :_id for reference: #{value.class}" unless value.key?(:_id)

        "{:db/id #{value[:_id]}}"
      else
        raise ArgumentError, "Unsupported value type: #{value.class}"
      end
    end

    def self.to_datomic_string(value)
      # https://github.com/relevance/edn-ruby/blob/master/lib/edn/core_ext.rb#L36
      array = value.chars.map do |ch|
        if %w[" \\].include?(ch)
          "\\#{ch}"
        else
          ch
        end
      end
      "\"#{array.join}\""
    end

    def self.to_datomic_instant(value)
      time = case value
             when Time
               value
             when Date
               value.to_time
             end

      "#inst \"#{time.utc.strftime('%Y-%m-%dT%H:%M:%S.%L%:z')}\""
    end

    def self.ruby_to_datomic_type(ruby_type)
      case ruby_type
      when :string    then ':db.type/string'
      when :long      then ':db.type/long'
      when :boolean   then ':db.type/boolean'
      when :double    then ':db.type/double'
      when :instant   then ':db.type/instant'
      when :keyword   then ':db.type/keyword'
      when :uuid      then ':db.type/uuid'
      when :ref       then ':db.type/ref'
      when :bigdec    then ':db.type/bigdec'
      when :bigint    then ':db.type/bigint'
      when :uri       then ':db.type/uri'
      else
        raise ArgumentError, "Unknown type: #{ruby_type}"
      end
    end

    def self.ruby_to_datomic_cardinality(cardinality)
      case cardinality
      when :one  then ':db.cardinality/one'
      when :many then ':db.cardinality/many'
      else
        raise ArgumentError, "Unknown cardinality: #{cardinality}"
      end
    end

    def self.ruby_to_datomic_unique(unique_type)
      case unique_type
      when :identity then ':db.unique/identity'
      when :value    then ':db.unique/value'
      when nil       then nil
      else
        raise ArgumentError, "Unknown uniqueness constraint: #{unique_type}"
      end
    end

    def self.datomic_to_ruby_type(datomic_type)
      datomic_type = ":#{datomic_type}" unless datomic_type.start_with?(':')
      case datomic_type
      when ':db.type/bigdec'  then :bigdec
      when ':db.type/bigint'  then :bigint
      when ':db.type/boolean' then :boolean
      when ':db.type/bytes'   then :bytes
      when ':db.type/double'  then :double
      when ':db.type/float'   then :float
      when ':db.type/instant' then :instant
      when ':db.type/keyword' then :keyword
      when ':db.type/long'    then :long
      when ':db.type/ref'     then :ref
      when ':db.type/string'  then :string
      when ':db.type/symbol'  then :symbol
      when ':db.type/tuple'   then :tuple
      when ':db.type/uuid'    then :uuid
      when ':db.type/uri'     then :uri
      else
        raise ArgumentError, "Unknown Datomic type: #{datomic_type}"
      end
    end

    def self.datomic_to_ruby_unique(datomic_unique)
      datomic_unique = ":#{datomic_unique}" unless datomic_unique.start_with?(':')
      case datomic_unique
      when ':db.unique/value' then :value
      when ':db.unique/identity' then :identity
      else
        raise ArgumentError, "Unknown Datomic uniqueness: #{datomic_unique}"
      end
    end

    def self.datomic_to_ruby_cardinality(datomic_cardinality)
      datomic_cardinality = ":#{datomic_cardinality}" unless datomic_cardinality.start_with?(':')
      case datomic_cardinality
      when ':db.cardinality/one' then :one
      when ':db.cardinality/many' then :many
      else
        raise ArgumentError, "Unknown Datomic cardinality: #{datomic_cardinality}"
      end
    end
  end
end
