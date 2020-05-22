class Choices::Provider
  attr_accessor :data, :partial, :json

  def initialize(data:, partial: false, json: nil)
    self.data = data
    self.partial = partial
    self.json = json
  end

  def as_json(options={})
    {
        partial: partial,
        choices: self.json || data.as_json
    }
  end

end