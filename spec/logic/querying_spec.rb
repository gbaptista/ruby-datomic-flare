# frozen_string_literal: true

require './logic/querying'

RSpec.describe Flare::QueryingLogic do
  describe '.entity_to_dsl' do
    context 'when given a flat hash with movie data' do
      it 'transforms it to a nested hash with correct structure' do
        input_data = {
          ':movie/title' => 'Repo Man',
          ':movie/genre' => 'punk dystopia',
          ':movie/release_year' => 1984,
          ':db/id' => 17_592_186_045_430
        }

        expected_output = {
          movie: {
            title: 'Repo Man',
            genre: 'punk dystopia',
            release_year: 1984,
            _id: 17_592_186_045_430
          }
        }

        transformed_data = described_class.entity_to_dsl(input_data)
        expect(transformed_data).to eq(expected_output)
      end
    end

    context 'when given a nested hash with movie and director data' do
      it 'transforms it to a nested hash with correct structure' do
        input_data = {
          ':movie/title' => 'Repo Man',
          ':movie/genre' => 'punk dystopia',
          ':movie/release_year' => 1984,
          ':db/id' => 17_592_186_045_430,
          ':movie/director' => {
            ':db/id' => 1,
            ':director/name' => 'John'
          }
        }

        expected_output = {
          movie: {
            title: 'Repo Man',
            genre: 'punk dystopia',
            release_year: 1984,
            _id: 17_592_186_045_430,
            director: {
              _id: 1,
              name: 'John'
            }
          }
        }

        transformed_data = described_class.entity_to_dsl(input_data)
        expect(transformed_data).to eq(expected_output)
      end
    end

    context 'when given a hash with multiple nested entities' do
      it 'correctly transforms it into a nested structure' do
        input_data = {
          ':movie/title' => 'Repo Man',
          ':movie/genre' => 'punk dystopia',
          ':db/id' => 17_592_186_045_430,
          ':movie/director' => {
            ':db/id' => 1,
            ':director/name' => 'John',
            ':director/age' => 42
          },
          ':movie/producer' => {
            ':db/id' => 2,
            ':producer/name' => 'Alice'
          }
        }

        expected_output = {
          movie: {
            title: 'Repo Man',
            genre: 'punk dystopia',
            _id: 17_592_186_045_430,
            director: {
              _id: 1,
              name: 'John',
              age: 42
            },
            producer: {
              _id: 2,
              name: 'Alice'
            }
          }
        }

        transformed_data = described_class.entity_to_dsl(input_data)
        expect(transformed_data).to eq(expected_output)
      end
    end

    context 'when given a deeply nested structure' do
      it 'transforms it to a deeply nested structure correctly' do
        input_data = {
          ':movie/title' => 'Repo Man',
          ':movie/genre' => 'punk dystopia',
          ':db/id' => 17_592_186_045_430,
          ':movie/director' => {
            ':db/id' => 1,
            ':director/name' => 'John',
            ':director/agency' => {
              ':db/id' => 2,
              ':agency/name' => 'Creative Artists',
              ':agency/location' => {
                ':db/id' => 3,
                ':location/city' => 'Los Angeles',
                ':location/state' => 'CA'
              }
            }
          }
        }

        expected_output = {
          movie: {
            title: 'Repo Man',
            genre: 'punk dystopia',
            _id: 17_592_186_045_430,
            director: {
              _id: 1,
              name: 'John',
              agency: {
                _id: 2,
                name: 'Creative Artists',
                location: {
                  _id: 3,
                  city: 'Los Angeles',
                  state: 'CA'
                }
              }
            }
          }
        }

        transformed_data = described_class.entity_to_dsl(input_data)
        expect(transformed_data).to eq(expected_output)
      end
    end

    context 'when given an empty entity' do
      it 'returns an empty entity' do
        input_data = {
          ':db/id' => 461_168_118_077_963
        }

        transformed_data = described_class.entity_to_dsl(input_data)
        expect(transformed_data).to be_nil
      end
    end
  end
end
