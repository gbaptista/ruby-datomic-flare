# frozen_string_literal: true

require 'uuidx'

require_relative '../../static/gem'
require_relative '../../controllers/client'

module Flare
  def self.new(...)
    Controllers::Client.new(...)
  end

  def self.uuid
    Uuidx
  end

  def self.version
    Flare::GEM[:version]
  end
end
