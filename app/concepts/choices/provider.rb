class Choices::Provider
  attr_accessor :data, :partial, :json, :provider, :headers

  def initialize(provider:, headers: nil, data:, partial: false, json: nil)
    self.provider = provider
    self.data = data
    self.partial = partial
    self.headers = headers
    self.json = json
  end

  def as_json(options = {})
    json = {
        partial: partial,
        choices: self.json || data.as_json
    }
    json[:headers] = headers
    json
  end

end