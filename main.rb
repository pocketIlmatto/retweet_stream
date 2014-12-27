require_relative 'retweet_stream'

puts "Enter rolling window length in minutes:"
user_minutes = Integer(gets.chomp) rescue nil
until user_minutes.is_a? Integer and user_minutes > 0
  puts "Rolling window length in minutes must be an integer > 0:"
  user_minutes = Integer(gets.chomp) rescue nil
end
retweet_window = RetweetStream.new
retweet_window.window_minutes = user_minutes
retweet_window.stream
