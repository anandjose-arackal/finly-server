class Forms::API
  include Forms::Definitions::DSL
  include Forms::Builders::Contract
  include Forms::Builders::Filters
  # include Forms::Builders::Configuration

  def self.master
    return (@master ||= {}) if self == Forms::API

    # Ensure all masters are always referencing the API.master
    @master ||= Forms::API.master
  end

  class << self
    delegate :[], :[]=, to: :master
  end
end