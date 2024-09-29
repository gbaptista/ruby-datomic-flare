# frozen_string_literal: true

require_relative 'types'

module Flare
  module TransactingLogic
    def self.retractions_to_edn(namespace, retractions)
      edn = retractions.map do |retraction|
        retraction_to_edn(namespace, retraction)
      end

      "[#{edn.join("\n ")}]"
    end

    def self.retraction_to_edn(namespace, retraction)
      id = retraction[:_id]

      attributes = retraction.except(:_id)

      if attributes.empty?
        # Built-In Transaction Functions
        # https://docs.datomic.com/transactions/transaction-functions.html#built-in
        "[:db/retractEntity #{id}]"
      else
        attributes.map do |attribute, value|
          if value.nil?
            "[:db/retract #{id} :#{namespace}/#{attribute}]"
          else
            "[:db/retract #{id} :#{namespace}/#{attribute} #{TypesLogic.to_datomic_value(value)}]"
          end
        end
      end
    end

    def self.transactions_to_edn(namespace, transactions)
      edn = transactions.map do |transaction|
        attributes = transaction.map.with_index do |(attribute, value), i|
          ident = if %i[_id _temporary_id].include?(attribute)
                    ':db/id'
                  else
                    ":#{namespace}/#{attribute}"
                  end

          "#{i.zero? ? '' : '  '}#{ident} #{TypesLogic.to_datomic_value(value)}"
        end.join("\n")

        "{#{attributes}}"
      end.join("\n ")

      "[#{edn}]"
    end
  end
end
