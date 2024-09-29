# frozen_string_literal: true

module Flare
  module Errors
    class FlareError < StandardError
      def initialize(message = nil)
        super
      end
    end

    class RequestError < FlareError
      attr_reader :request, :payload

      def initialize(message = nil, request: nil, payload: nil)
        @request = request
        @payload = payload

        super(message)
      end
    end
  end
end
