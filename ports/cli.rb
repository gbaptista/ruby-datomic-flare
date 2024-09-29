# frozen_string_literal: true

require 'dotenv/load'

require_relative '../controllers/documentation/generator'

module Flare
  module CLI
    def self.handle(command)
      case command
      when 'docs:generate'
        Flare::Controllers::Documentation::Generator.handler
      else
        puts 'Invalid command.'
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  if ARGV.empty?
    puts 'No command provided.'
  else
    Flare::CLI.handle(ARGV[0])
  end
end
