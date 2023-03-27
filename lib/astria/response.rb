# frozen_string_literal: true

module Astria

  # The Response represents a response returned by a client request.
  #
  # It wraps the content of the response data, as well other response metadata such as rate-limiting information.
  class Response

    # @return [HTTParty::Response]
    attr_reader :http_response

    # @return [Struct::Base, Array] The content of the response data field.
    attr_reader :data

    # @param  [HTTParty::Response] http_response the HTTP response
    # @param  [Object] data the response data
    def initialize(http_response, data)
      @http_response = http_response
      @data = data
    end

  end

  # CollectionResponse is a specific type of Response
  # where the data is a collection of enumerable objects.
  class CollectionResponse < Response

  end

end
