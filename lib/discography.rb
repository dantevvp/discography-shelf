require_relative '../api/spotify'
require_relative '../api/trello'

class Discography
  attr_reader :cache, :album_api

  COVERS_FILE = 'covers.json'.freeze
  BOARD_NAME = 'Discography'.freeze

  class CoversCache
    def initialize(filename)
      @filename = filename
      @json = init_cache
    end

    def init_cache
      File.write(@filename, '{}') unless File.exist?(@filename)
      file = File.read(@filename)
      JSON.parse(file)
    end

    def key_transform(album)
      key = "#{album.year}_#{album.title}"
      key.gsub(/[^0-9A-Za-z.\-]/, '_')
    end

    def [](album)
      key = key_transform(album)
      @json[key]
    end

    def []=(album, url)
      key = key_transform(album)
      @json[key] = url
    end

    def save
      File.write(@filename, JSON.dump(@json))
    end
  end

  class Album
    attr_reader :year, :title, :cover_url

    def initialize(discography, year, title)
      @discography = discography
      @year = year
      @title = title
      @cover_url = fetch_cover_url
    end

    def fetch_cover_url
      cached_cover_url = @discography.cache[self]
      return cached_cover_url unless cached_cover_url.nil?

      fetched_album = @discography.album_api.find_album_by(album: @title, year: @year)
      return if fetched_album.nil? || fetched_album['images'].empty?

      cover_url = fetched_album['images'].first['url']
      @discography.cache[self] = cover_url
      cover_url
    end
  end

  def initialize(file)
    @shelf_api = API::Trello.new
    @album_api = API::Spotify.new
    @cache = CoversCache.new(COVERS_FILE)
    @content = fetch_from_file(file)
  end

  def save
    @cache.save
  end

  def sort!
    @content.sort_by! { |album| [album.year, album.title] }
    self
  end

  def albums_by_decade
    @content.group_by { |album| album.year.floor(-1) }
  end

  def inspect
    inspect_id = ::Kernel::format '%x', (object_id * 2)
    %(#<#{self.class}:0x#{inspect_id}>)
  end

  def to_s
    @content.to_s
  end

  def empty?
    @content.nil? || @content.empty?
  end

  def generate_trello_display
    @shelf_api.delete_all_boards
    board_id = @shelf_api.create_board(name: BOARD_NAME)
    albums_by_decade.each do |decade, albums|
      list_id = @shelf_api.create_list(name: decade, board: board_id)
      albums.each do |album|
        description = "#{album.year} - #{album.title}"
        @shelf_api.create_card(title: description, cover: album.cover_url, list: list_id)
      end
    end
  end

  private

  def fetch_from_file(file)
    File.open(file).map do |line|
      pair = line.split(/\s/, 2)
      Album.new(self, pair.first.to_i, pair.last.strip)
    end
  end
end
