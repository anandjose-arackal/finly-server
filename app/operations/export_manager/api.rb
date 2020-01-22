class ExportManager::API
  include EventBus::Subscriber
  include Supporters::ErrorTracker
  include DynamicAttributes
  include ExportManager::DSL::Config
  include ExportManager::DSL::Generator
  include ExportManager::DSL::DataProvider
  include ExportManager::DSL::Job
  include ExportManager::DSL::Validator
  include ExportManager::DSL::EventProcessor

  attr_accessor :user, :params

  bus ExportManager::Master

  def initialize(user, params)
    self.user = user
    self.params = params
  end
end