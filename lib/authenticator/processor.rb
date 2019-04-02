class Authenticator::Processor
  attr_accessor :params, :user, :provider, :request

  PROVIDERS = [
      Authenticator::Providers::Application,
      Authenticator::Providers::Admin,
      Authenticator::Providers::AdminBypass
  ]

  def initialize(request)
    self.request = request
    self.params = request.params
  end

  def authenticate
    self.provider = fetch_provider
    raise "AuthProvider not found" if self.provider.nil?

    self.provider.authenticate
  end

  def fetch_provider
    PROVIDERS.each {|provider| return provider.new(self.params) if provider.accept?(self.params)}
    nil
  end

end