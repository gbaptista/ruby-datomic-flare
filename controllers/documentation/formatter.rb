# frozen_string_literal: true

require 'rubocop'
require 'pp'
require 'tempfile'

module Flare
  module Controllers
    module Documentation
      module Formatter
        def self.to_s_and_format(ruby_object)
          code = PP.pp(ruby_object, String.new)

          format_code(code)
        end

        def self.format_code(code)
          Tempfile.create(['code', '.rb']) do |file|
            file.write(code)
            file.flush

            options = { autocorrect: true, formatters: [], cache: false }

            config_store = RuboCop::ConfigStore.new
            config_store.options_config = './docs/templates/.rubocop.yml'

            runner = RuboCop::Runner.new(options, config_store)

            runner.run([file.path])

            File.read(file.path).strip
          end
        end
      end
    end
  end
end
