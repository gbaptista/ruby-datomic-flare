# frozen_string_literal: true

require_relative '../helpers/h'

require_relative 'types'

module Flare
  module SchemaLogic
    QUERY = <<~EDN
      [:find
          ?e ?ident ?value_type ?cardinality ?doc
          ?unique ?index ?no_history
       :in $
       :where
         [?e :db/ident ?ident]

         [?e :db/valueType ?value_type_id]
         [?value_type_id :db/ident ?value_type]

         [?e :db/cardinality ?cardinality_id]
         [?cardinality_id :db/ident ?cardinality]

         [(get-else $ ?e :db/doc "") ?doc]

         [(get-else $ ?e :db/unique -1) ?unique_id]
         [(get-else $ ?unique_id :db/ident false) ?unique]

         [(get-else $ ?e :db/index false) ?index]
         [(get-else $ ?e :db/noHistory false) ?no_history]]
    EDN

    NON_SCHEMA_NAMESPACES = %w[
      db
      db.alter db.attr db.bootstrap db.cardinality db.entity db.excise
      db.fn db.install db.lang db.part db.sys db.type db.unique
      fressian
    ].freeze

    def self.specification_to_edn(specification)
      edn_schema = specification.flat_map do |namespace, attributes|
        attributes.map.with_index do |(attribute, options), i|
          fields = [
            "#{i.zero? ? '' : ' '}{:db/ident       :#{namespace}/#{attribute}",
            "  :db/valueType   #{TypesLogic.ruby_to_datomic_type(options[:type])}",
            "  :db/cardinality #{TypesLogic.ruby_to_datomic_cardinality(options[:cardinality] || :one)}"
          ]

          fields << "  :db/doc         \"#{options[:doc]}\"" if options[:doc]
          fields << "  :db/unique      #{TypesLogic.ruby_to_datomic_unique(options[:unique])}" if options[:unique]
          fields << '  :db/index       true' if options[:index]
          fields << '  :db/noHistory   true' if options[:history] == false

          fields[fields.size - 1] = "#{fields.last}}"

          fields.join("\n")
        end
      end.join("\n\n")

      "[#{edn_schema}]"
    end

    def self.datoms_to_specification(datoms)
      specification = {}

      datoms.filter do |datom|
        !NON_SCHEMA_NAMESPACES.include?(datom[1].split('/').first)
      end.each do |entry|
        namespace, attribute = entry[1].split('/')
        type = TypesLogic.datomic_to_ruby_type(entry[2])
        cardinality = TypesLogic.datomic_to_ruby_cardinality(entry[3])
        doc = entry[4].empty? ? nil : entry[4]

        unique = entry[5] ? TypesLogic.datomic_to_ruby_unique(entry[5]) : false
        indexed = entry[6]
        no_history = entry[7]

        specification[namespace] ||= {}
        specification[namespace][attribute] = {
          type:,
          cardinality:,
          doc:,
          unique:,
          index: indexed,
          history: !no_history
        }
      end

      H.symbolize_keys(specification)
    end
  end
end
