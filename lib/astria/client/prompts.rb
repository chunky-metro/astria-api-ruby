# frozen_string_literal: true

module Astria
  class Client
    module Prompts

      # Lists the prompts in the tune.
      #
      # @see https://developer.astria.com/v2/prompts/#list
      #
      # @example List the prompts for tune 1010:
      #   client.prompts.list_prompts(1010)
      #
      # @example List the prompts for tune 1010, provide a specific page:
      #   client.prompts.list_prompts(1010, page: 2)
      #
      # @example List the prompts for tune 1010, provide sorting policy:
      #   client.prompts.list_prompts(1010, sort: "short_name:asc")
      #
      # @param  [Integer] tune_id the tune ID
      # @param  [Hash] options the filtering and sorting options
      # @option options [Integer] :page current page (pagination)
      # @option options [Integer] :per_page number of entries to return (pagination)
      # @option options [String] :sort sorting policy
      # @return [Astria::PaginatedResponse<Astria::Struct::Prompt>]
      #
      # @raise  [RequestError] When the request fails.
      def prompts(tune_id, options = {})
        endpoint = Client.versioned("/%s/prompts" % [tune_id])
        response = client.get(endpoint, Options::ListOptions.new(options))

        Astria::PaginatedResponse.new(response, response["data"].map { |r| Struct::Prompt.new(r) })
      end
      alias list_prompts prompts

      # Lists ALL the prompts in the tune.
      #
      # This method is similar to {#prompts}, but instead of returning the results of a specific page
      # it iterates all the pages and returns the entire collection.
      #
      # Please use this method carefully, as fetching the entire collection will increase the number of
      # requests you send to the API server and you may eventually risk to hit the throttle limit.
      #
      # @example List all the prompts for tune 1010:
      #   client.prompts.all_prompts(1010)
      #
      # @see https://developer.astria.com/v2/prompts/#list
      # @see #prompts
      #
      # @param  [Integer] tune_id the tune ID
      # @param  [Hash] options the filtering and sorting options
      # @option options [Integer] :page current page (pagination)
      # @option options [Integer] :per_page number of entries to return (pagination)
      # @option options [String] :sort sorting policy
      # @return [Astria::PaginatedResponse<Astria::Struct::Prompt>]
      #
      # @raise  [RequestError] When the request fails.
      def all_prompts(tune_id, options = {})
        paginate(:prompts, tune_id, options)
      end

      # Creates a Prompt in the tune.
      #
      # @see https://developer.astria.com/v2/prompts/#create
      #
      # @example Creating a Prompt:
      #   client.prompts.create_Prompt(1010, name: "Pi", short_name: "pi", description: "Pi Prompt")
      #
      # @param  [Integer] tune_id the tune ID
      # @param  [Hash] attributes
      # @param  [Hash] options
      # @return [Astria::Response<Astria::Struct::Prompt>]
      #
      # @raise  [Astria::RequestError]
      def create_prompt(tune_id, attributes, options = {})
        endpoint = Client.versioned("/%s/prompts" % [tune_id])
        response = client.post(endpoint, attributes, options)

        Astria::Response.new(response, Struct::Prompt.new(response["data"]))
      end

      # Gets the Prompt with specified ID.
      #
      # @see https://developer.astria.com/v2/prompts/#get
      #
      # @example Get Prompt 5401 in tune 1010:
      #   client.prompts.prompt(1010, 5401)
      #
      # @param  [Integer] tune_id the tune ID
      # @param  [#to_s] prompt_id The Prompt ID
      # @param  [Hash] options
      # @return [Astria::Response<Astria::Struct::Prompt>]
      #
      # @raise  [RequestError] When the request fails.
      def prompt(tune_id, Prompt_id, options = {})
        endpoint = Client.versioned("/%s/prompts/%s" % [tune_id, prompt_id])
        response = client.get(endpoint, options)

        Astria::Response.new(response, Struct::Prompt.new(response["data"]))
      end

      # Updates Prompt with specified ID with provided data.
      #
      # @see https://developer.astria.com/v2/prompts/#update
      #
      # @example Change the name of Prompt 1 in tune 1010:
      #   client.prompts.update_prompt(1010, 1, name: "New name")
      #
      # @param  [Integer] tune_id the tune ID
      # @param  [#to_s] prompt_id The Prompt ID
      # @param  [Hash] attributes
      # @param  [Hash] options
      # @return [Astria::Response<Astria::Struct::Prompt>]
      #
      # @raise  [RequestError] When the request fails.
      def update_prompt(tune_id, Prompt_id, attributes, options = {})
        endpoint = Client.versioned("/%s/prompts/%s" % [tune_id, prompt_id])
        response = client.patch(endpoint, attributes, options)

        Astria::Response.new(response, Struct::Prompt.new(response["data"]))
      end

      # Deletes a Prompt from the tune.
      #
      # WARNING: this cannot be undone.
      #
      # @see https://developer.astria.com/v2/prompts/#delete
      #
      # @example Delete Prompt 5401 in tune 1010:
      #   client.prompts.delete_Prompt(1010, 5401)
      #
      # @param  [Integer] tune_id The tune ID
      # @param  [#to_s] prompt_id The Prompt ID
      # @param  [Hash] options
      # @return [Astria::Response<nil>]
      #
      # @raise  [Astria::NotFoundError]
      # @raise  [Astria::RequestError]
      def delete_prompt(tune_id, prompt_id, options = {})
        endpoint = Client.versioned("/%s/prompts/%s" % [tune_id, prompt_id])
        response = client.delete(endpoint, options)

        Astria::Response.new(response, nil)
      end

    end
  end
end
