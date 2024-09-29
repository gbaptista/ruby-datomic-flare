# frozen_string_literal: true

require './logic/schema'

RSpec.describe Flare::SchemaLogic do
  describe '.datoms_to_specification' do
    context 'when given an array of datoms' do
      it 'generates the related schema specification' do
        datoms = [
          [73, 'movie/genre', 'db.type/string', 'db.cardinality/one', 'The genre of the movie.', false, false, false],
          [71, 'db.attr/preds', 'db.type/symbol', 'db.cardinality/many', '', false, false, false],
          [7, 'db/system-tx', 'db.type/keyword', 'db.cardinality/many', '', false, false, false],
          [65, 'db/tupleType', 'db.type/keyword', 'db.cardinality/one', '', false, false, false],
          [17, 'db.excise/beforeT', 'db.type/long', 'db.cardinality/one', '', false, false, false],
          [80, 'xpto/colors', 'db.type/string', 'db.cardinality/many', 'Rainbow.', false, false, true],
          [69, 'db.entity/attrs', 'db.type/keyword', 'db.cardinality/many', '', false, false, false],
          [68, 'db/ensure', 'db.type/ref', 'db.cardinality/many', '', false, false, false],
          [76, 'user/country', 'db.type/string', 'db.cardinality/one', '', false, false, false],
          [70, 'db.entity/preds', 'db.type/symbol', 'db.cardinality/many', '', false, false, false],
          [72, 'movie/title', 'db.type/string', 'db.cardinality/one', 'The title of the movie.', false, false, false],
          [78, 'post/content', 'db.type/string', 'db.cardinality/one', 'The content of the post.', false, false, false],
          [77, 'post/title', 'db.type/string', 'db.cardinality/one', 'The title of the post.', false, false, false],
          [75, 'user/name', 'db.type/string', 'db.cardinality/one', '', false, false, false],
          [74, 'movie/release_year', 'db.type/long', 'db.cardinality/one',
           'The year the movie was released in theaters.', false, false, false],
          [66, 'db/tupleTypes', 'db.type/tuple', 'db.cardinality/one', '', false, false, false],
          [18, 'db.excise/before', 'db.type/instant', 'db.cardinality/one', '', false, false, false],
          [79, 'xpto/email', 'db.type/string', 'db.cardinality/one', '', 'db.unique/value', true, false],
          [67, 'db/tupleAttrs', 'db.type/tuple', 'db.cardinality/one', '', false, false, false]
        ]

        specification = described_class.datoms_to_specification(datoms)

        expected_specification = {
          movie: { genre: { type: :string, cardinality: :one, doc: 'The genre of the movie.', unique: false, index: false, history: true },
                   title: { type: :string, cardinality: :one, doc: 'The title of the movie.', unique: false, index: false,
                            history: true },
                   release_year: { type: :long, cardinality: :one, doc: 'The year the movie was released in theaters.',
                                   unique: false, index: false, history: true } },
          xpto: { colors: { type: :string, cardinality: :many, doc: 'Rainbow.', unique: false, index: false, history: false },
                  email: { type: :string, cardinality: :one, doc: nil, unique: :value, index: true,
                           history: true } },
          user: { country: { type: :string, cardinality: :one, doc: nil, unique: false, index: false, history: true },
                  name: { type: :string, cardinality: :one, doc: nil, unique: false, index: false,
                          history: true } },
          post: { content: { type: :string, cardinality: :one, doc: 'The content of the post.', unique: false, index: false, history: true },
                  title: { type: :string, cardinality: :one, doc: 'The title of the post.', unique: false, index: false,
                           history: true } }
        }

        expect(specification).to eq(expected_specification)
      end
    end
  end

  describe '.specification_to_edn' do
    context 'when given a valid schema specification' do
      it 'generates the EDN transaction data' do
        specification = {
          author: {
            email: { type: :string, unique: :value, index: true },
            name: { type: :string, unique: :identity, history: false },
            xpto: { type: :double }
          }
        }

        expected_edn = <<~EDN.strip
          [{:db/ident       :author/email
            :db/valueType   :db.type/string
            :db/cardinality :db.cardinality/one
            :db/unique      :db.unique/value
            :db/index       true}

           {:db/ident       :author/name
            :db/valueType   :db.type/string
            :db/cardinality :db.cardinality/one
            :db/unique      :db.unique/identity
            :db/noHistory   true}

           {:db/ident       :author/xpto
            :db/valueType   :db.type/double
            :db/cardinality :db.cardinality/one}]
        EDN

        edn = described_class.specification_to_edn(specification)

        expect(edn).to eq(expected_edn)
      end

      it 'generates the EDN transaction data' do
        specification = {
          post: {
            title: { type: :string },
            content: { type: :string, doc: 'The content of the post.' },
            tags: { type: :string, cardinality: :many, doc: 'The tags of the post.' }
          }
        }

        expected_edn = <<~EDN.strip
          [{:db/ident       :post/title
            :db/valueType   :db.type/string
            :db/cardinality :db.cardinality/one}

           {:db/ident       :post/content
            :db/valueType   :db.type/string
            :db/cardinality :db.cardinality/one
            :db/doc         "The content of the post."}

           {:db/ident       :post/tags
            :db/valueType   :db.type/string
            :db/cardinality :db.cardinality/many
            :db/doc         "The tags of the post."}]
        EDN

        edn = described_class.specification_to_edn(specification)

        expect(edn).to eq(expected_edn)
      end

      it 'generates the EDN transaction data' do
        specification = {
          movie: {
            title: { type: :string, doc: 'The title of the movie.' },
            genre: { type: :string, doc: 'The genre of the movie.' },
            release_year: { type: :long, doc: 'The year the movie was released in theaters.' }
          }
        }

        expected_edn = <<~EDN.strip
          [{:db/ident       :movie/title
            :db/valueType   :db.type/string
            :db/cardinality :db.cardinality/one
            :db/doc         "The title of the movie."}

           {:db/ident       :movie/genre
            :db/valueType   :db.type/string
            :db/cardinality :db.cardinality/one
            :db/doc         "The genre of the movie."}

           {:db/ident       :movie/release_year
            :db/valueType   :db.type/long
            :db/cardinality :db.cardinality/one
            :db/doc         "The year the movie was released in theaters."}]
        EDN

        edn = described_class.specification_to_edn(specification)

        expect(edn).to eq(expected_edn)
      end

      it 'generates the EDN transaction data' do
        specification = {
          artist: { songs: { type: :string, cardinality: :many } }
        }

        expected_edn = <<~EDN.strip
          [{:db/ident       :artist/songs
            :db/valueType   :db.type/string
            :db/cardinality :db.cardinality/many}]
        EDN

        edn = described_class.specification_to_edn(specification)

        expect(edn).to eq(expected_edn)
      end
    end
  end
end
