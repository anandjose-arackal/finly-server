Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env.production?
    provider :quickbooks, 'qyprdcbNAAUAdPe5BTq7VVoSohnmb9', 'canDspIG9JUVXNLqle2zGzw2dACOOubtjkyt8LRv'
  else
    provider :quickbooks, 'qyprd0zDADfuZkLhAUxBfCWOZD9arh', 'UmdQJxfAd5Y7VZlCxF1gACyz60HWgI1hEXGkZImj'
  end
end