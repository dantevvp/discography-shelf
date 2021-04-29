require 'httparty'

module API
  class Base
    include HTTParty

    attr_reader :token

    # this method will be called everytime an API class is instantiated
    # it will call the authorization endpoint on the chosen API and set the correct headers for the next requests
    def initialize
      authorize_api
    end

    def default_headers
      {}
    end

    def stringify_query(query_hash)
      query_hash.map { |e| e.join(':') }.join(' ')
    end

    def handle_errors(response)
      raise StandardError, "ERROR #{response.code}: #{response}" unless response.ok?
    end

    def handle_success(response)
      response['id']
    end

    # override this method if the API needs authentication
    def authorize_api; end
  end
end
