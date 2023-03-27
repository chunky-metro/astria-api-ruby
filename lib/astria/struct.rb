# frozen_string_literal: true

module Astria
  module Struct

    class Base
      def initialize(attributes = {})
        attributes.each do |key, value|
          m = "#{key}=".to_sym
          send(m, value) if respond_to?(m)
        end
      end
    end

  end
end

require_relative 'struct/client'
require_relative 'struct/prompt'
require_relative 'struct/tune'