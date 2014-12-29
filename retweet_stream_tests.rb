require 'minitest/autorun'
require_relative 'retweet_stream'

class RetweetStreamTest < MiniTest::Unit::TestCase

  def test_initialize_window_minutes
    retweet_window = RetweetStream.new
    retweet_window.window_minutes = 10
    assert_equal 10, retweet_window.window_minutes
  end

  def test_update_retweeted_tweets_add
    retweet_window = RetweetStream.new
    retweet_window.update_retweeted_tweets("123", 1)
    retweet_window.update_retweeted_tweets("123", 1)
    retweet_window.update_retweeted_tweets("123", 1)

    assert_equal 3, retweet_window.retweeted_tweets["123"][0]
  end

  def test_update_retweeted_tweets_subtract
    retweet_window = RetweetStream.new
    retweet_window.update_retweeted_tweets("123", 1)
    retweet_window.update_retweeted_tweets("123", -1)
    
    assert_equal 0, retweet_window.retweeted_tweets["123"][0]
  end

  def test_cleanup_retweet_window
    retweet_window = RetweetStream.new
    retweet_window.window_minutes = 10

    retweet_window.retweets << [10, 9, Time.now-15*60]
    retweet_window.retweets << [13, 9, Time.now-8*60]
    retweet_window.retweets << [18, 11, Time.now-8*60]
    retweet_window.retweets << [20, 11, Time.now-7*60]
    retweet_window.retweets << [25, 9, Time.now-6*60]
    retweet_window.retweets << [30, 9, Time.now-5*60]
    retweet_window.retweets << [35, 11, Time.now-4*60]
    retweet_window.retweets << [40, 11, Time.now-1*60]
    retweet_window.cleanup_retweet_window


    assert_equal 7, retweet_window.retweets.length
  end

  def test_find_top_ten
    retweet_window = RetweetStream.new
    retweet_window.window_minutes = 10

    retweet_window.retweets << [10, 9, Time.now-15*60]
    retweet_window.update_retweeted_tweets(9, 1)
    retweet_window.retweets << [13, 9, Time.now-8*60]
    retweet_window.update_retweeted_tweets(9, 1)
    retweet_window.retweets << [18, 11, Time.now-8*60]
    retweet_window.update_retweeted_tweets(11, 1)
    retweet_window.retweets << [20, 11, Time.now-7*60]
    retweet_window.update_retweeted_tweets(11, 1)
    retweet_window.retweets << [25, 9, Time.now-6*60]
    retweet_window.update_retweeted_tweets(9, 1)
    retweet_window.retweets << [30, 9, Time.now-5*60]
    retweet_window.update_retweeted_tweets(9, 1)
    retweet_window.retweets << [35, 11, Time.now-4*60]
    retweet_window.update_retweeted_tweets(11, 1)
    

    assert_equal 4, retweet_window.find_top_ten[0][1][0] #retweets count
  end


end