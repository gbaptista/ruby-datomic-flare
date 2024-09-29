# frozen_string_literal: true

require 'bigdecimal'
require 'securerandom'

RSpec.describe 'Datomic Flare Client', :peer do
  context 'when multiple types are defined in a schema' do
    it 'transact and read data in the expected types' do
      skip 'Missing some formats.'
      # %w[bigint bytes ref symbol tuple uuid uri]
    end

    it 'transact and read data in the expected types' do
      expect(@flare.meta['meta']['mode']).to eq('peer')

      types = %w[
        bigdec boolean double float
        instant keyword long string
      ]

      types_as_edn = types.map do |type|
        <<~EDN
          {:db/ident       :lemon/my_#{type}
           :db/valueType   :db.type/#{type}
           :db/cardinality :db.cardinality/one}
        EDN
      end

      expect do
        @flare.api.transact!(
          { data: "[#{types_as_edn.join("\n").strip}]" }
        )
      end.not_to raise_error

      id = nil

      expect do
        id = @flare.dsl.assert_into!(
          :lemon,
          {
            my_bigdec: BigDecimal('34567890.123456'),
            my_boolean: true,
            my_double: 1.79,
            my_float: 3.40282320,
            my_keyword: :some_key_13_word!,
            my_instant: Time.utc(2023, 9, 28, 23, 59, 59),
            my_long: -9_223_372_036_854_775_807,
            my_string: 'The "fire" \'blade\'.'
          }
        )
      end.not_to raise_error

      entity = @flare.dsl.find_by_entity_id(id)

      expect(entity[:lemon][:_id]).to eq(id)
      expect(entity[:lemon][:my_bigdec]).to eq(BigDecimal('34567890.123456'))
      expect(entity[:lemon][:my_boolean]).to be(true)
      expect(entity[:lemon][:my_double]).to eq(1.79)
      expect(entity[:lemon][:my_float]).to eq(3.40282320)
      expect(entity[:lemon][:my_keyword]).to eq(':some_key_13_word!')
      expect(entity[:lemon][:my_instant]).to eq('2023-09-28T23:59:59Z')
      expect(entity[:lemon][:my_long]).to eq(-9_223_372_036_854_775_807)
      expect(entity[:lemon][:my_string]).to eq('The "fire" \'blade\'.')
    end
  end

  context 'when interacting with entities' do
    let(:schema) do
      {
        post: {
          title: { type: :string, doc: 'The title of the post.' },
          content: { type: :string, doc: 'The content of the post.' },
          author: { type: :ref, doc: 'The author of the post.' },
          tags: { type: :string, cardinality: :many, doc: 'The tags of the post.' }
        },
        author: {
          email: { type: :string, unique: :value, doc: 'The email of the author.' },
          name: { type: :string, doc: 'The name of the author.' }
        }
      }
    end

    it 'transact and read data in the expected types' do
      expect(@flare.meta['meta']['mode']).to eq('peer')

      expect do
        @flare.dsl.transact_schema!(schema, database: @database_name)
      end.not_to raise_error

      transact_response_data = @flare.dsl.assert_into!(
        :author,
        { name: 'Violet Rain', email: 'violet@mail.com' },
        database: @database_name, raw: true
      )

      expect(transact_response_data['meta']['database'].keys.sort).to eq(
        %w[name value].sort
      )

      expect(transact_response_data['data'].keys).to eq(
        %w[db-before db-after tx-data tempids]
      )

      expect(transact_response_data['data']['tx-data'].first).to be_a(Array)
      expect(transact_response_data['data']['tx-data'].first.size).to eq(5)

      author_id = @flare.dsl.assert_into!(
        :author,
        { name: 'Purple Rain', email: 'purple@mail.com' },
        database: @database_name
      )

      expect(author_id).not_to be_nil

      posts_data = [
        { title: 'Hello World', content: 'Hello world!',
          author: author_id,
          tags: %w[rainbow winter] },
        { title: 'Purple Updates', content: 'We are painting the world purple.',
          author: author_id }
      ]

      post_ids = @flare.dsl.assert_into!(
        :post, posts_data, database: @database_name
      )

      expect(post_ids).not_to be_empty

      author_entity = @flare.api.entity(
        { database: { latest: true, name: @database_name },
          id: author_id }
      )

      expect(author_entity['data'].keys.sort).to eq(
        [':db/id', ':author/name', ':author/email'].sort
      )

      first_post_entity = @flare.api.entity(
        { database: { latest: true, name: @database_name },
          id: post_ids[0] }
      )

      expect(first_post_entity['data'].keys.sort).to eq(
        [':db/id', ':post/author', ':post/content', ':post/tags', ':post/title'].sort
      )

      expect(first_post_entity['data'][':post/author'].keys.sort).to eq(
        [':db/id', ':author/email', ':author/name'].sort
      )
    end
  end
end
