#retweet_stream
Uses Twitter's sample streaming API to show the top 10 retweeted tweets in a rolling window of time, where the window's start is n minutes ago (where n is defined by the user) and the window's end is the current time.

Output continuously updates and includes the tweet text and number of times retweeted (based on retweets processed by the program, not the retweet_count) in the current rolling window.
 
##Setup
Create twitter.yml file with api tokens & secrets 
``` 
consumer_key: ''
consumer_secret: ''
access_token: ''
access_token_secret: ''
```
Run bundle install
```bundle install```

##Run tests
```ruby retweet_stream_tests.rb```
##Start streaming
```ruby main.rb```
