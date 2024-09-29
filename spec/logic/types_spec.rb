# frozen_string_literal: true

require 'uri'
require 'bigdecimal'

require './logic/types'

RSpec.describe Flare::TypesLogic do
  describe '.to_datomic_value' do
    context 'when given a ruby value' do
      it 'converts it to an edn value that will be recognized by Datomic' do
        skip 'Missing some formats.'

        # bytes
        expect(
          described_class.to_datomic_value([0, 255, 128, 64, 32].pack('C*'))
        ).to eq('TODO')

        # tuple
        expect(
          described_class.to_datomic_value([42, 12, 'foo'])
        ).to eq('TODO')

        # uuid
        expect(
          described_class.to_datomic_value('dc195321-b707-4c19-a8a9-9c51c9f5e2da')
        ).to eq('#uuid "dc195321-b707-4c19-a8a9-9c51c9f5e2da"')

        # uri
        expect(
          described_class.to_datomic_value(
            URI.parse('https://site.com/path/index.html?with=complex&query=params#fragment')
          )
        ).to eq('"https://site.com/path/index.html?with=complex&query=params#fragment"')

        # symbol
        expect(
          described_class.to_datomic_value(:some_symbol)
        ).to eq('some_symbol')

        # bigint
        expect(
          described_class.to_datomic_value(
            12_345_678_901_234_567_890_123_456_789_012_345_678_901_234_567_890
          )
        ).to eq('12345678901234567890123456789012345678901234567890M')
      end

      it 'converts it to an edn value that will be recognized by Datomic' do
        # bigdec
        expect(
          described_class.to_datomic_value(
            BigDecimal('123456789012345678901234567890.123456789012345678901234567890')
          )
        ).to eq('123456789012345678901234567890.12345678901234567890123456789M')

        # boolean
        expect(described_class.to_datomic_value(true)).to eq('true')

        # boolean
        expect(described_class.to_datomic_value(false)).to eq('false')

        # double
        expect(
          described_class.to_datomic_value(1.7976931348623157e+308)
        ).to eq('1.7976931348623157e+308')

        # float
        expect(
          described_class.to_datomic_value(3.4028235e+38)
        ).to eq('3.4028235e+38')

        # instant
        expect(
          described_class.to_datomic_value(Time.utc(2023, 9, 28, 23, 59, 59))
        ).to eq('#inst "2023-09-28T23:59:59.000+00:00"')

        # instant
        expect(
          described_class.to_datomic_value(Date.new(2023, 9, 28))
        ).to eq('#inst "2023-09-28T03:00:00.000+00:00"')

        # instant
        expect(
          described_class.to_datomic_value(DateTime.new(2023, 9, 28, 23, 59, 59))
        ).to eq('#inst "2023-09-28T23:59:59.000+00:00"')

        # keyword
        expect(
          described_class.to_datomic_value(:some_key_13_word!)
        ).to eq(':some_key_13_word!')

        # long
        expect(
          described_class.to_datomic_value(-9_223_372_036_854_775_807)
        ).to eq('-9223372036854775807')

        # ref
        expect(
          described_class.to_datomic_value(
            789
          )
        ).to eq('789')

        # string
        expect(described_class.to_datomic_value('Fire')).to eq('"Fire"')

        # string
        expect(
          described_class.to_datomic_value('The "fire" \'blade\'.')
        ).to eq('"The \\"fire\\" \'blade\'."')
      end
    end
  end
end
