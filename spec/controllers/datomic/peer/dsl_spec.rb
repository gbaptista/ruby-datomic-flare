# frozen_string_literal: true

RSpec.describe 'Flare Client', :peer do
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

  it 'creates the schema and inserts data' do
    expect(@flare.meta['meta']['mode']).to eq('peer')

    expect do
      @flare.dsl.transact_schema!(schema, database: @database_name)
    end.not_to raise_error

    fetched_schema = @flare.dsl.schema(database: @database_name)
    expect(fetched_schema).not_to be_empty
    expect(fetched_schema[:post]).to include(:title, :content, :author, :tags)
    expect(fetched_schema[:author]).to include(:email, :name)

    author_data = { name: 'Purple Rain', email: 'purple@mail.com' }

    author_id = @flare.dsl.assert_into!(
      :author, author_data, database: @database_name
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
    expect(post_ids.size).to eq(2)
    expect(post_ids).not_to include(nil)

    author_entity = @flare.dsl.find_by_entity_id(author_id, database: @database_name)
    expect(author_entity[:author][:name]).to eq('Purple Rain')
    expect(author_entity[:author][:email]).to eq('purple@mail.com')

    first_post_entity = @flare.dsl.find_by_entity_id(
      post_ids[0], database: @database_name
    )

    expect(first_post_entity[:post][:tags]).to eq(%w[rainbow winter])

    post_ids.each do |post_id|
      post_entity = @flare.dsl.find_by_entity_id(post_id, database: @database_name)
      expect(post_entity[:post][:author][:_id]).to eq(author_id)
    end

    query_result = @flare.dsl.query(
      database: @database_name,
      datalog: <<~EDN
        [:find ?title ?content ?author_name ?author_email
         :where [?id :post/title ?title]
                [?id :post/content ?content]
                [?id :post/author ?author_id]
                [?author_id :author/name ?author_name]
                [?author_id :author/email ?author_email]]
      EDN
    ).sort_by { |result| result[0] }

    expect(query_result).not_to be_empty

    expect(query_result[0]).to eq(
      ['Hello World', 'Hello world!',
       'Purple Rain', 'purple@mail.com']
    )

    expect(query_result[1]).to eq(
      ['Purple Updates', 'We are painting the world purple.',
       'Purple Rain', 'purple@mail.com']
    )
  end
end
