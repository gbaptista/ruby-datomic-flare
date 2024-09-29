# frozen_string_literal: true

require_relative 'static/gem'

Gem::Specification.new do |spec|
  spec.name    = Flare::GEM[:name]
  spec.version = Flare::GEM[:version]
  spec.authors = [Flare::GEM[:author]]

  spec.summary = Flare::GEM[:summary]
  spec.description = Flare::GEM[:description]

  spec.homepage = Flare::GEM[:github]

  spec.license = Flare::GEM[:license]

  spec.required_ruby_version = Gem::Requirement.new(">= #{Flare::GEM[:ruby]}")

  spec.metadata['allowed_push_host'] = Flare::GEM[:gem_server]

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = Flare::GEM[:github]

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{\A(?:test|spec|features)/})
    end
  end

  spec.require_paths = ['ports/dsl']

  spec.add_dependency 'faraday', '~> 2.12'
  spec.add_dependency 'faraday-typhoeus', '~> 1.1'
  spec.add_dependency 'typhoeus', '~> 1.4', '>= 1.4.1'

  spec.add_dependency 'bigdecimal', '~> 3.1', '>= 3.1.8'

  spec.add_dependency 'uuidx', '~> 0.10.0'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
