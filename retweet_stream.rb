require 'tweetstream'
require 'yaml'

class RetweetStream
  
  attr_accessor :window_minutes
  attr_reader :original_tweets
  attr_reader :twitter_statuses
  attr_accessor :retweets

  def initialize
    twitter_config = YAML.load_file("twitter.yml")

    @tweet_stream = TweetStream.configure do |config|
      config.consumer_key = twitter_config['consumer_key']
      config.consumer_secret = twitter_config['consumer_secret']
      config.oauth_token = twitter_config['access_token']
      config.oauth_token_secret = twitter_config['access_token_secret']
      config.auth_method = :oauth
    end

    @retweets = [] #array of arrays: [[retweet-id, original-tweet-id, timestamp]]
    @original_tweets = Hash.new{0} #hash to aggregate retweet counts {tweet-id => retweet-count}
    @current_top_ten = [] #stores the current top ten, so if it doesn't change, we don't reprint
    @twitter_statuses = {} #stores the status of any tweets that have been in the top ten {tweet-id => status}
    #TODO if possible, later combine original_tweets & twitter_statuses into a single hash {tweet-id => [retweet-count, status]}
        
  end

  def stream
    TweetStream::Client.new.on_delete{ |status_id, user_id|
      #a status was deleted
      #if this is a retweet in the time window, delete it and update Top10
      @retweets.delete_if do |retweet|
        if retweet[0] == status_id
          update_original_tweets(retweet[1], -1)
          true
        end
      end
      print_top_ten 
    }.on_limit { |skip_count|
      puts "Rate limited #{skip_count}"
    }.on_error { |message|
      puts "Some other error: #{message}"
    }.sample do |status|
      if status.retweeted_status?
        @retweets.push([status.id, status.retweeted_status.id, status.created_at])
        update_original_tweets(status.retweeted_status.id, 1)
        unless @twitter_statuses.has_key?(status.retweeted_status.id) 
          @twitter_statuses[status.retweeted_status.id] = status.retweeted_status.text 
        end
        
        cleanup_retweet_window

        print_top_ten
      end
    end
  end

  def update_original_tweets(id, increment)
    @original_tweets[id] += increment
    if (@original_tweets[id] < 1)
      @original_tweets.delete(id)
      @twitter_statuses.delete(id) 
    end
  end

  #drop any retweets outside timeframe
  def cleanup_retweet_window
    current_time = Time.now
    cutoff_time = current_time - window_minutes*(60)
    drop_index = 0
    @retweets.each do |retweet|
      if retweet[2] < cutoff_time #retweet[2] is the timestamp of the retweet
        drop_index += 1
        update_original_tweets(retweet[1], -1)
      else
        break
      end
    end
    @retweets = @retweets.drop(drop_index)
  end

  #this function could possibly be condensed to a few lines but I erred on the side of readability over elegance
  def find_top_ten
    sorted_tweets = @original_tweets.sort_by {|k, v| v}.reverse
    top_number = sorted_tweets.length > 10 ? 10 : sorted_tweets.length
    sorted_tweets = sorted_tweets.take(top_number)
  end

  def print_top_ten
    if @original_tweets.length > 1 
      sorted_tweets = find_top_ten
      diff = sorted_tweets - @current_top_ten unless @current_top_ten.nil?
      if @current_top_ten.nil? || !diff.empty?
        puts "***********"
        puts "Top #{sorted_tweets.length} retweeted tweets in last #{window_minutes} minute(s):"
        sorted_tweets.each do |tweet|
          puts "Retweets #{tweet[1]}: #{@twitter_statuses[tweet[0]]} "
        end
        puts "***********"
        @current_top_ten = sorted_tweets
      end 
    end
  end
end



