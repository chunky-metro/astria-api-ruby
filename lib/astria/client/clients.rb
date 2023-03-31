# frozen_string_literal: true

module Astria
  class Client

    # @return [Astria::Client::PromptsService] The tunes-related API proxy.
    def prompts
      @services[:templates] ||= Client::TemplatesService.new(self)
    end

    # @return [Astria::Client::TunesService] The tunes-related API proxy.
    def tunes
      @services[:tunes] ||= Client::TunesService.new(self)
    end

    # Struct
    class ClientService

      # @return [Astria::Client]
      attr_reader :client

      def initialize(client)
        @client = client
      end

      # Internal helper that loops over a paginated response and returns all the records in the collection.
      #
      # @api private
      #
      # @param  [Symbol] method The client method to execute
      # @param  [Array] args The args to call the method with
      # @return [Astria::CollectionResponse]
      def paginate(method, *args)
        current_page = 0
        total_pages = nil
        collection = []
        options = args.pop
        response = nil

        loop do
          current_page += 1
          query = Extra.deep_merge(options, query: { page: current_page, per_page: 100 })

          response = send(method, *(args + [query]))
          total_pages ||= response.total_pages
          collection.concat(response.data)
          break unless current_page < total_pages
        end

        CollectionResponse.new(response.http_response, collection)
      end

    end


    require_relative 'tunes'

    class TunesService < ClientService
      include Client::Tunes
    end


    require_relative 'prompts'

    class PromptsService < ClientService
      include Client::Prompts
    end

  end

  module V1
    extend Client::Identity::StaticHelpers
  end
end
