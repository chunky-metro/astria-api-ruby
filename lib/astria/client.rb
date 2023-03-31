# frozen_string_literal: true

require 'httparty'
require 'astria/extra'
require 'astria/struct'
require 'astria/response'
require 'astria/client/clients'

module Astria

  # Client for the Astria API
  #
  # @see https://developer.astria.com/
  # @see https://developer.astria.com/sandbox/
  # @see #base_url
  #
  # @example Default (Production)
  #   require "astria"
  #
  #   client = Astria::Client.new(access_token: "abc")
  #
  # @example Custom Base URL (Sandbox)
  #   require 'astria'
  #
  #   client = Astria::Client.new(base_url: "https://api.sandbox.astria.com", access_token: "abc")
  class Client

    HEADER_AUTHORIZATION = "Authorization"

    # @return [String] The current API version.
    API_VERSION = "v2"


    # Prepends the correct API version to +path+.
    #
    # @return [String] The versioned path.
    def self.versioned(path)
      File.join(API_VERSION, path)
    end


    # @!attribute username
    #   @see https://developer.astria.com/v2/#authentication
    #   @return [String] Astria username for Basic Authentication
    attr_accessor :username

    # @!attribute password
    #   @see https://developer.astria.com/v2/#authentication
    #   @return [String] Astria password for Basic Authentication
    attr_accessor :password

    # @!attribute domain_api_token
    #   @see https://developer.astria.com/v2/#authentication
    #   @return [String] Domain API access token for authentication
    attr_accessor :domain_api_token

    # @!attribute access_token
    #   @see https://developer.astria.com/v2/#authentication
    #   @return [String] Domain API access token for authentication
    attr_accessor :access_token

    # @!attribute user_agent
    #   @return [String] Configure User-Agent header for requests.
    attr_accessor :user_agent

    # @!attribute proxy
    #   @return [String,nil] Configure address:port values for proxy server
    attr_accessor :proxy


    def initialize(options = {})
      defaults = Astria::Default.options

      Astria::Default.keys.each do |key| # rubocop:disable Style/HashEachMethods
        instance_variable_set(:"@#{key}", options[key] || defaults[key])
      end

      @services = {}
    end


    # Base URL for API requests.
    #
    # It defaults to <tt>"https://api.astria.com"</tt>.
    # For testing purposes use <tt>"https://api.sandbox.astria.com"</tt>.
    #
    # @return [String] Base URL
    #
    # @see https://developer.astria.com/sandbox/
    #
    # @example Default (Production)
    #   require "astria"
    #
    #   client = Astria::Client.new(access_token: "abc")
    #
    # @example Custom Base URL (Sandbox)
    #   require 'astria'
    #
    #   client = Astria::Client.new(base_url: "https://api.sandbox.astria.com", access_token: "abc")
    def base_url
      Extra.join_uri(@base_url, "")
    end


    # Make a HTTP GET request.
    #
    # @param  [String] path The path, relative to {#base_url}
    # @param  [Hash] options The query and header params for the request
    # @return [HTTParty::Response]
    def get(path, options = {})
      execute :get, path, nil, options.to_h
    end

    # Make a HTTP POST request.
    #
    # @param  [String] path The path, relative to {#base_url}
    # @param  [Hash] data The body for the request
    # @param  [Hash] options The query and header params for the request
    # @return [HTTParty::Response]
    def post(path, data = nil, options = {})
      execute :post, path, data, options
    end

    # Make a HTTP PUT request.
    #
    # @param  [String] path The path, relative to {#base_url}
    # @param  [Hash] data The body for the request
    # @param  [Hash] options The query and header params for the request
    # @return [HTTParty::Response]
    def put(path, data = nil, options = {})
      execute :put, path, data, options
    end

    # Make a HTTP PATCH request.
    #
    # @param  [String] path The path, relative to {#base_url}
    # @param  [Hash] data The body for the request
    # @param  [Hash] options The query and header params for the request
    # @return [HTTParty::Response]
    def patch(path, data = nil, options = {})
      execute :patch, path, data, options
    end

    # Make a HTTP DELETE request.
    #
    # @param  [String] path The path, relative to {#base_url}
    # @param  [Hash] options The query and header params for the request
    # @return [HTTParty::Response]
    def delete(path, data = nil, options = {})
      execute :delete, path, data, options
    end

    # Executes a request, validates and returns the response.
    #
    # @param  [String] method The HTTP method
    # @param  [String] path The path, relative to {#base_url}
    # @param  [Hash] data The body for the request
    # @param  [Hash] options The query and header params for the request
    # @return [HTTParty::Response]
    # @raise  [RequestError]
    # @raise  [NotFoundError]
    # @raise  [AuthenticationFailed]
    # @raise  [TwoFactorAuthenticationRequired]
    def execute(method, path, data = nil, options = {})
      response = request(method, path, data, options)

      case response.code
      when 200..299
        response
      when 401
        raise AuthenticationFailed, response["message"]
      when 404
        raise NotFoundError, response
      else
        raise RequestError, response
      end
    end

    # Make a HTTP request.
    #
    # This method doesn't validate the response and never raise errors
    # even in case of HTTP error codes, except for connection errors raised by
    # the underlying HTTP client.
    #
    # Therefore, it's up to the caller to properly handle and validate the response.
    #
    # @param  [String] method The HTTP method
    # @param  [String] path The path, relative to {#base_url}
    # @param  [Hash] data The body for the request
    # @param  [Hash] options The query and header params for the request
    # @return [HTTParty::Response]
    def request(method, path, data = nil, options = {})
      request_options = request_options(options)

      if data
        request_options[:headers]["Content-Type"] = content_type(request_options[:headers])
        request_options[:body] = content_data(request_options[:headers], data)
      end

      HTTParty.send(method, base_url + path, request_options)
    end


    private

    def request_options(custom_options = {})
      base_options.tap do |options|
        Extra.deep_merge!(options, custom_options)
        Extra.deep_merge!(options, headers: { "User-Agent" => format_user_agent })
        add_auth_options!(options)
        add_proxy_options!(options)
      end
    end

    def base_options
      {
        format: :json,
        headers: {
          "Accept" => "application/json",
        },
      }
    end

    def add_proxy_options!(options)
      return if proxy.nil?

      address, port = proxy.split(":")
      options[:http_proxyaddr] = address
      options[:http_proxyport] = port
    end

    def add_auth_options!(options)
      if password
        options[:basic_auth] = { username: username, password: password }
      elsif access_token
        options[:headers][HEADER_AUTHORIZATION] = "Bearer #{access_token}"
      end
    end

    # Builds the final user agent to use for HTTP requests.
    #
    # If no custom user agent is provided, the default user agent is used.
    #
    #     astria-ruby/1.0
    #
    # If a custom user agent is provided, the final user agent is the combination
    # of the default user agent prepended by the custom user agent.
    #
    #     customAgentFlag astria-ruby/1.0
    #
    def format_user_agent
      if user_agent.to_s.empty?
        Astria::Default::USER_AGENT
      else
        "#{user_agent} #{Astria::Default::USER_AGENT}"
      end
    end

    def content_type(headers)
      headers["Content-Type"] || "application/json"
    end

    def content_data(headers, data)
      headers["Content-Type"] == "application/json" ? JSON.dump(data) : data
    end

  end
end
