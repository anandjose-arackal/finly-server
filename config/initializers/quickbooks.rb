OAUTH_CONSUMER_KEY = "qyprd0zDADfuZkLhAUxBfCWOZD9arh"
OAUTH_CONSUMER_SECRET = "UmdQJxfAd5Y7VZlCxF1gACyz60HWgI1hEXGkZImj"

::QB_OAUTH_CONSUMER = OAuth::Consumer.new(OAUTH_CONSUMER_KEY, OAUTH_CONSUMER_SECRET, {
  :site                 => "https://oauth.intuit.com",
  :request_token_path   => "/oauth/v1/get_request_token",
  :authorize_url        => "https://appcenter.intuit.com/Connect/Begin",
  :access_token_path    => "/oauth/v1/get_access_token"
})