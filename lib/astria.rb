# frozen_string_literal: true

module Astria

  # Echoes a deprecation warning message.
  #
  # @param  [String] message The message to display.
  # @return [void]
  #
  # @api internal
  # @private
  def self.deprecate(message = nil)
    message ||= "You are using deprecated behavior which will be removed from the next major or minor release."
    warn("DEPRECATION WARNING: #{message}")
  end

end

require 'astria/version'
require 'astria/default'
require 'astria/client'
require 'astria/error'
require 'astria/options'
