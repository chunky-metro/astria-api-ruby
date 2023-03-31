# frozen_string_literal: true

module Astria

  # Default configuration options for {Client}
  module Default

    # Default API endpoint
    BASE_URL = "https://api.astria.com/"

    # Default User Agent header
    USER_AGENT = "astria-ruby/#{VERSION}".freeze

    class << self

      # List of configurable keys for {Client}
      # @return [Array] of option keys
      def keys
        @keys ||= [
          :base_url,
          :username,
          :password,
          :access_token,
          :domain_api_token,
          :user_agent,
          :proxy,
        ]
      end

      # Configuration options
      # @return [Hash]
      def options
        keys.to_h { |key| [key, send(key)] }
      end

      # Default API endpoint from ENV or {BASE_URL}
      # @return [String]
      def base_url
        ENV.fetch('ASTRIA_BASE_URL', BASE_URL)
      end

      # Default Astria access token for OAuth authentication from ENV
      # @return [String]
      def api_key
        ENV.fetch('ASTRIA_API_KEY') { raise 'ASTRIA_API_KEY not set.' }
      end

    end
  end

end
