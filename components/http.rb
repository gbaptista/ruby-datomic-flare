# frozen_string_literal: true

require 'faraday'
require 'faraday/typhoeus'
require 'json'
require_relative '../components/errors'

module Flare
  module HTTP
    DEFAULT_ADDRESS = 'http://localhost:3042'
    ALLOWED_REQUEST_OPTIONS = %i[timeout open_timeout read_timeout write_timeout].freeze
    DEFAULT_FARADAY_ADAPTER = :typhoeus

    class Client
      def initialize(config)
        @address = if config[:credentials][:address].to_s.strip.empty?
                     DEFAULT_ADDRESS
                   else
                     config[:credentials][:address].to_s.sub(
                       %r{/$}, ''
                     )
                   end

        @request_options = config.dig(:options, :connection, :request)&.slice(*ALLOWED_REQUEST_OPTIONS) || {}
        @faraday_adapter = config.dig(:options, :connection, :adapter) || DEFAULT_FARADAY_ADAPTER
      end

      def request(path, payload = nil, debug:, request_method: 'POST')
        url = "#{@address}/#{path}"
        method = request_method.to_s.strip.downcase.to_sym

        if debug
          debug_payload = { method: method.to_s.upcase, url: }

          debug_payload[:body] = JSON.parse(payload.to_json) unless payload.nil?

          return debug_payload
        end

        response = Faraday.new(request: @request_options) do |faraday|
          faraday.adapter @faraday_adapter
          faraday.response :raise_error
        end.send(method) do |req|
          req.url url
          req.headers['Content-Type'] = 'application/json'
          req.body = payload.to_json unless payload.nil?
        end

        JSON.parse(response.body)
      rescue Faraday::Error => e
        raise Errors::RequestError.new("#{e.message}: #{e.response[:body]}", request: e, payload:)
      end
    end
  end
end
