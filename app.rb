#ruby
require 'dotenv/load'
require 'json'
require_relative 'lib/discography'

filename = 'discography.txt'

discog = Discography.new(filename).sort!

if discog.empty?
  puts 'Error: no albums to put on display!'
  puts "Check your #{filename} file to see if it has anything"
  exit
end
discog.save
discog.generate_trello_display
