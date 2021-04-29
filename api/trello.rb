require_relative 'base'

module API
  class Trello < Base
    MAX_ATTEMPTS = 5
    API_URI = ENV['TRELLO_API_BASE_URI']
    AUTH_URI = ENV['TRELLO_API_AUTH_URI']
    API_KEY = ENV['TRELLO_API_KEY']
    API_SECRET = ENV['TRELLO_API_SECRET']
    EP = {
      boards: '/boards',
      search: '/search',
      lists: '/lists',
      cards: '/cards',
      attachments: '/attachments',
      member: '/members/me'
    }.freeze

    base_uri API_URI
    headers 'Authorization' => "OAuth oauth_consumer_key=\"#{API_KEY}\", oauth_token=\"#{API_SECRET}\""

    # create a board
    def create_board(name:)
      puts "creating board: #{name}"
      response = self.class.post(EP[:boards], body: { name: name, defaultLabels: false, defaultLists: false })
      handle_errors(response)
      handle_success(response)
    end

    # create a list in a board
    def create_list(name:, board:)
      puts "creating board: #{name}"
      response = self.class.post(EP[:lists], body: { name: name, idBoard: board, pos: 'bottom' })
      handle_errors(response)
      handle_success(response)
    end

    # create a card in a list
    def create_card(title:, list:, cover: nil)
      puts "creating card: #{title}"
      response = self.class.post(
        EP[:cards],
        body: { name: title, idList: list, urlSource: cover }
      )
      handle_errors(response)
      handle_success(response)
    end

    # get all boards
    def boards
      self.class.get(EP[:member] + EP[:boards]).parsed_response
    end

    # get lists from a board
    def lists(board:)
      self.class.get("#{EP[:boards]}/#{board}#{EP[:lists]}").parsed_response
    end

    # get cards from a list
    def cards(list:)
      self.class.get("#{EP[:lists]}/#{list}#{EP[:cards]}").parsed_response
    end

    # delete a board
    def delete_board(board_id)
      puts "deleting board: #{board_id}"
      response = self.class.delete("#{EP[:boards]}/#{board_id}")
      handle_errors(response)
      board_id
    end

    # delete all boards, just in case multiple boards have been created
    def delete_all_boards
      boards.map do |board|
        delete_board(board['id'])
      end
    end
  end
end
