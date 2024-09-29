# frozen_string_literal: true

require 'liquid'
require 'babosa'

require 'json'

require_relative 'formatter'
require_relative '../../ports/dsl/datomic-flare'
require_relative '../../static/gem'

module Flare
  module Controllers
    module Documentation
      module Generator
        FLARE_AS_PEER_ADDRESS = ENV.fetch('FLARE_AS_PEER_ADDRESS', nil)
        FLARE_SOURCE = ENV.fetch('FLARE_SOURCE', nil)

        def self.handler
          generate_individual_documentations!
          generate_consolidated_readme!
          generate_flare_readme!
        end

        def self.generate_flare_readme!
          unless File.exist?("#{FLARE_SOURCE}/deps.edn")
            warn "Couldn't find datomic-flare project at '#{FLARE_SOURCE}/deps.edn'"
            return
          end

          template_path = "#{FLARE_SOURCE}/docs/templates/README.md"
          rendered_path = "#{FLARE_SOURCE}/docs/README.md"
          readme_path = "#{FLARE_SOURCE}/README.md"

          create_database_and_generate_documentation!(template_path)

          quick_starts = Dir[
            "#{FLARE_SOURCE}/docs/quick-start/*/README.md"
          ].map do |path|
            markdown = File.read(path)
            source_path = Dir["#{File.dirname(path)}/flare.*"].first
            language = File.extname(source_path).sub('.', '')
            source = File.read(source_path)

            "#{markdown}\n\n```#{language}\n#{source.strip}\n```"
          end

          content_with_quick_starts = Liquid::Template.parse(
            File.read(rendered_path)
          ).render(
            stringify_keys(
              {
                quick_starts: quick_starts.join("\n\n")
              }
            )
          )

          content = Liquid::Template.parse(File.read(rendered_path)).render(
            stringify_keys(
              {
                index: generate_index(content_with_quick_starts),
                quick_starts: quick_starts.join("\n\n")
              }
            )
          )

          puts "> Generating final datomic-flare/README.md: '#{readme_path}'"

          File.write(readme_path, content)
        end

        def self.generate_consolidated_readme!
          content = Liquid::Template.parse(File.read('./docs/README.md')).render(
            stringify_keys(
              {
                gem: GEM,
                dsl: File.read('./docs/dsl.md'),
                api: File.read('./docs/api.md')
              }
            )
          )

          content = Liquid::Template.parse(File.read('./docs/README.md')).render(
            stringify_keys(
              {
                index: generate_index(content),
                gem: GEM,
                dsl: Liquid::Template.parse(
                  File.read('./docs/dsl.md')
                ).render(stringify_keys({ gem: GEM })),
                api: Liquid::Template.parse(
                  File.read('./docs/api.md')
                ).render(stringify_keys({ gem: GEM }))
              }
            )
          )

          puts "> Generating final README: './README.md'"

          File.write('./README.md', content)
        end

        def self.generate_index(content)
          sections = []

          urls = {}

          content.lines.each do |line|
            next unless line.strip.start_with?('#')

            base_url = line.strip.split(/#\s+/).last.strip.to_slug.normalize.to_s
            url = base_url

            url_index = 0

            while urls.key?(url)
              url_index += 1
              url = "#{base_url}-#{url_index}"
            end

            urls[url] = true

            sections << {
              title: line.strip.split(/#\s+/).last.strip,
              url:,
              level: line.strip.split(/\s/).first.strip.size,
              raw: line
            }
          end

          sections.map do |section|
            if section[:level] <= 1
              nil
            else
              "#{'  ' * (section[:level] - 2)}- [#{section[:title]}](##{section[:url]})"
            end
          end.compact.join("\n")
        end

        def self.generate_individual_documentations!
          Dir['./docs/templates/*.md'].each do |path|
            create_database_and_generate_documentation!(path)
          end
        end

        def self.create_database_and_generate_documentation!(path)
          puts "> Connecting to Datomic: '#{FLARE_AS_PEER_ADDRESS}'"

          database_name = "my-datomic-database-docs-#{Flare.uuid.v7}"

          client = Flare.new(
            credentials: { address: FLARE_AS_PEER_ADDRESS },
            dangerously_override: { database: { name: database_name } }
          )

          puts "> Creating database: '#{database_name}'"
          client.dsl.create_database!(database_name)

          begin
            state = { database_name: }
            generate_documentation!(client, state, path)
          ensure
            puts "> Destroying database: '#{database_name}'"
            client.dsl.destroy_database!(database_name)
          end
        end

        def self.generate_documentation!(client, state, path)
          puts "> Generating documentation: #{path}"
          output = run_and_populate_runnable_codes!(client, state, path)
          output_path = path.sub('docs/templates/', 'docs/')
          File.write(output_path, output)
          puts "> Documentation generated: #{output_path}"
        end

        def self.run_and_populate_runnable_codes!(client, state, path)
          output = []
          buffer = nil
          next_placeholder = nil
          File.readlines(path).each do |line|
            if line.strip.start_with?('```') && !buffer.nil?
              meta = buffer[:meta].strip.gsub(/`+/, '').split(':')
              language = meta[0]
              tag = meta[1] ? meta[1].split('/')[0] : nil
              action = meta[1] ? meta[1].split('/')[1] : nil

              output << "```#{language}\n" if tag != 'state' && !['to-request', 'render->to-request'].include?(action)

              if %w[bash json].include?(language) &&
                 tag == 'placeholder' &&
                 next_placeholder
                output << if action == 'to-curl'
                            to_curl(next_placeholder)
                          elsif action == 'to-json'
                            to_json(next_placeholder)
                          else
                            next_placeholder[:formatted]
                          end

                next_placeholder = nil if action != 'to-curl'
              elsif language == 'ruby'
                source_code = buffer[:lines].join

                if ['render', 'render->to-request'].include?(action)
                  source_code = Liquid::Template.parse(source_code).render(
                    stringify_keys({ state: })
                  )
                end

                formatted_code = Formatter.format_code(source_code).strip

                if tag == 'state'
                  execution = execute_code(
                    client, state,
                    next_placeholder ? next_placeholder[:result] : nil,
                    formatted_code
                  )
                  state = execution[:state]
                elsif tag == 'runnable'
                  output << formatted_code unless ['to-request', 'render->to-request'].include?(action)

                  if ['to-request', 'render->to-request'].include?(action)
                    execution = execute_code(
                      client, state.merge({ debug: true }), nil, formatted_code
                    )

                    state = execution[:state]

                    next_placeholder = {
                      request: execution[:result]
                    }

                    execution = execute_code(
                      client, state.merge({ debug: false }), nil, formatted_code
                    )

                    state = execution[:state]

                    next_placeholder[:result] = execution[:result]
                    next_placeholder[:response] = execution[:result]
                  else
                    execution = execute_code(client, state, nil, formatted_code)

                    state = execution[:state]

                    next_placeholder = { result: execution[:result] }

                    next_placeholder[:formatted] = Formatter.to_s_and_format(
                      next_placeholder[:result]
                    )
                  end
                elsif tag == 'placeholder' && next_placeholder
                  output << next_placeholder[:formatted]
                  next_placeholder = nil
                else
                  output << formatted_code
                end
              else
                output << buffer[:lines].join.strip
              end

              output << "\n```\n" if tag != 'state' && !['to-request', 'render->to-request'].include?(action)
              buffer = nil
            elsif line.strip.start_with?('```') && buffer.nil?
              buffer = { meta: line, lines: [] }
            elsif !buffer.nil?
              buffer[:lines] << line
            else
              output << line
            end
          end

          output.join
        end

        def self.to_curl(result)
          http_method = result[:request][:method]
          url = result[:request][:url]
          body = result[:request][:body]

          body = body&.except('connection')

          body['database'] = body['database']&.except('name') if body&.key?('database')

          if body&.key?('inputs')
            body['inputs'] = body['inputs'].map do |input|
              input['database'] = input['database'].except('name') if input.is_a?(Hash) && input.key?('database')
              input
            end
          end

          curl_command = ''

          if body && (body.key?('data') || body.key?('query'))
            key = body.key?('data') ? 'data' : 'query'

            <<~BB.strip
              echo '#{JSON.pretty_generate(body[key])}' | bb -e '(pr-str (edn/read-string (slurp *in*)))'
            BB

            placeholder = ":CAT#{Flare.uuid.v7}CAT:"

            edn_value = body[key]

            body[key] = placeholder

            curl_command = <<~CURL
              echo '
              #{edn_value.strip}
              ' \\
              | bb -e '(pr-str (edn/read-string (slurp *in*)))' \\
              | curl -s #{url} \\
                -X #{http_method} \\
                -H "Content-Type: application/json" \\
                --data-binary @- <<JSON \\
              | jq
              #{JSON.pretty_generate(body)}
              JSON
            CURL

            curl_command = curl_command.sub("\"#{placeholder}\"", '$(cat)')
          else
            json_body = body ? JSON.pretty_generate(body) : nil
            curl_command = <<~CURL
              curl -s #{url} \\
                -X #{http_method} \\
                -H "Content-Type: application/json" #{json_body ? "\\\n  -d '\n#{json_body}\n'" : ''} \\
              | jq
            CURL
          end

          curl_command.strip
        end

        def self.to_json(result)
          data = result[:response].except('meta')

          placeholder_key = ":JSON#{Flare.uuid.v7}JSON:"
          placeholder_values = []

          if data['data'].is_a?(Hash) && data['data']['tx-data']
            config = JSON::State.new(
              indent: ' ',
              space: ' ',
              array_nl: '',
              object_nl: ''
            )
            data['data']['tx-data'] = data['data']['tx-data'].each do |array|
              placeholder_values << JSON.generate(array, config).sub('[ ', '[')
            end
            data['data']['tx-data'] = [placeholder_key]
          end

          output = JSON.pretty_generate(data)

          output.sub(
            "\"#{placeholder_key}\"",
            placeholder_values.map.with_index do |value, i|
              i.zero? ? value : "      #{value}"
            end.join(",\n")
          )
        end

        def self.execute_code(client, state, result, code)
          context = binding
          context.local_variable_set(:client, client)
          context.local_variable_set(:state, state)
          context.local_variable_set(:result, result)
          result = context.eval(code)
          state = context.eval('state')
          { result:, state: }
        rescue Exception => e
          { result: { error: e.message }, state: }
        end

        def self.stringify_keys(object)
          result = {}

          object.each do |key, value|
            string_key = key.to_s

            result[string_key] = value.is_a?(Hash) ? stringify_keys(value) : value
          end

          result
        end
      end
    end
  end
end
