class Authenticator::Processor
  attr_accessor :params, :user, :provider

  PROVIDERS = [
      Authenticator::Providers::Application,
      Authenticator::Providers::Admin,
      Authenticator::Providers::AdminBypass
  ]

  def initialize(params)
    self.params = params
  end

  def authenticate
    self.provider = fetch_provider
    raise "Auth Provider not found" if self.provider.nil?

    self.provider.authenticate
  end

  def fetch_provider
    PROVIDERS.each {|provider| return provider.new(self.params) if provider.accept?(self.params)}
    nil
  end

end