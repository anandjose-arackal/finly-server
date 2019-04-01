class Authenticator
  attr_accessor :params, :user, :provider

  PROVIDERS = [
      Authenticator::Application,
      Authenticator::Admin,
      Authenticator::AdminBypass
  ]

  def initialize(params)
    self.params = params
    self.scopes = params&.dig(:scope)&.split(' ')
  end

  def authenticate
    self.provider = fetch_provider
    self.provider.authenticate
  end

  def fetch_provider
    PROVIDERS.each {|provider| return provider.new(self.params) if provider.accept?(self.params)}
  end

end