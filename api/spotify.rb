require_relative 'base'

module API
  class Spotify < Base
    API_URI = ENV['SPOTIFY_API_BASE_URI']
    AUTH_URI = ENV['SPOTIFY_API_AUTH_URI']
    EP = {
      search: '/search',
      auth: '/token'
    }.freeze
    ENCODED_TOKEN = Base64.strict_encode64("#{ENV['SPOTIFY_API_CLIENT_ID']}:#{ENV['SPOTIFY_API_CLIENT_SECRET']}").freeze

    base_uri API_URI
    headers 'Content-Type' => 'application/x-www-form-urlencoded'

    # method to authorize the spotify API. it sets the HTTParty class headers
    def authorize_api
      self.class.headers 'Authorization' => "Basic #{ENCODED_TOKEN}" # set authorization header
      response = self.class.post(
        EP[:auth],
        base_uri: AUTH_URI,
        body: 'grant_type=client_credentials'
      )
      token = response['access_token']
      raise StandardError, "ERROR #{response.code}: #{response['error']}" unless response.ok?

      self.class.headers 'Authorization' => "Bearer #{token}" # set new headers from now on
    end

    # search({ album: 'planet waves' }, type: 'album')
    # Pass a search query to the Spotify API
    def search(query, options = {})
      self.class.get(EP[:search], query: { q: stringify_query(query) }.merge(options))
    end

    # allowed keys are album, artist, year, genre
    def find_album_by(query)
      puts "finding album: #{query}"
      search(query, type: 'album', limit: 1).dig('albums', 'items').first
    end
  end
end
