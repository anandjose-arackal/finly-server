require 'factory_bot'
require 'faker'
# FactoryBot.find_definitions
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before do
    FactoryBot.find_definitions
  end
end