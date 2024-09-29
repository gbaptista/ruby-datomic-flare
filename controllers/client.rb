# frozen_string_literal: true

require_relative '../components/http'
require_relative '../logic/dangerous_override'

require_relative 'dsl'
require_relative 'api'

module Flare
  module Controllers
    class Client
      attr_reader :dangerously_override

      def initialize(config)
        @http_client = HTTP::Client.new(config)

        @dangerously_override = (config[:dangerously_override] || {}).freeze
      end

      def meta(debug: nil)
        request('meta', request_method: 'GET', debug:)
      end

      def api
        @api ||= API.new(self)
      end

      def dsl
        @dsl ||= DSL.new(self)
      end

      def request(path, payload = nil, debug:, request_method: 'POST')
        @http_client.request(
          path,
          DangerousOverrideLogic.apply_dangerous_overrides_to_payload(
            path, dangerously_override, payload
          ),
          request_method:, debug:
        )
      end
    end
  end
end
