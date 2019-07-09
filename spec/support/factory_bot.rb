require 'factory_bot'
require 'faker'
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  FactoryBot.find_definitions

  # config.before do
  #   debugger
  #   FactoryBot.find_definitions
  # end
end