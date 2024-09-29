# frozen_string_literal: true

require './logic/transacting'

RSpec.describe Flare::TransactingLogic do
  describe '.retractions_to_edn' do
    context 'when given a namespace and an array of retractions' do
      it 'generates the EDN transaction data' do
        retractions = [
          { _id: 17_592_186_045_428, genre: nil },
          { _id: 17_592_186_045_429, genre: 'future governor' },
          { _id: 17_592_186_045_430 }
        ]

        expected_edn = <<~EDN.strip
          [[:db/retract 17592186045428 :movie/genre]
           [:db/retract 17592186045429 :movie/genre "future governor"]
           [:db/retractEntity 17592186045430]]
        EDN

        edn = described_class.retractions_to_edn(:movie, retractions)

        expect(edn).to eq(expected_edn)
      end
    end
  end

  describe '.transactions_to_edn' do
    context 'when given a namespace and an array of transactions' do
      it 'generates the EDN transaction data' do
        transactions = [
          { _temporary_id: -1,
            title: 'The Goonies',
            genre: 'action/adventure',
            release_year: 1985 },
          { _temporary_id: -2,
            title: 'Commando',
            genre: 'action/adventure',
            release_year: 1985 }
        ]

        expected_edn = <<~EDN.strip
          [{:db/id -1
            :movie/title "The Goonies"
            :movie/genre "action/adventure"
            :movie/release_year 1985}
           {:db/id -2
            :movie/title "Commando"
            :movie/genre "action/adventure"
            :movie/release_year 1985}]
        EDN

        edn = described_class.transactions_to_edn(:movie, transactions)

        expect(edn).to eq(expected_edn)
      end

      it 'generates the EDN transaction data' do
        transactions = [
          { title: 'The Goonies',
            genre: 'action/adventure',
            release_year: 1985 },
          { title: 'Commando',
            genre: 'action/adventure',
            release_year: 1985 },
          { title: 'Repo Man',
            genre: 'punk dystopia',
            release_year: 1984 }
        ]

        expected_edn = <<~EDN.strip
          [{:movie/title "The Goonies"
            :movie/genre "action/adventure"
            :movie/release_year 1985}
           {:movie/title "Commando"
            :movie/genre "action/adventure"
            :movie/release_year 1985}
           {:movie/title "Repo Man"
            :movie/genre "punk dystopia"
            :movie/release_year 1984}]
        EDN

        edn = described_class.transactions_to_edn(:movie, transactions)

        expect(edn).to eq(expected_edn)
      end
    end
  end
end
