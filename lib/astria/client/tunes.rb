# frozen_string_literal: true

module Astria
  class Client
    module Tunes

      # Lists the tunes the authenticated entity has access to.
      #
      # @see https://developer.astria.com/v2/tunes
      #
      # @example List the tunes:
      #   client.tunes.list
      #
      # @param  [Hash] options
      # @return [Astria::Response<Astria::Struct::Account>]
      #
      # @raise  [Astria::RequestError]
      def tunes(options = {})
        response = client.get(Client.versioned("/tunes"), options)

        Astria::Response.new(response, response["data"].map { |r| Struct::Account.new(r) })
      end
      alias list_tunes tunes

    end
  end
end
