ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'test_helper'
require 'rails/test_help'
require 'sidekiq/testing'
# require 'minitest/autorun'
# require 'minitest/around/spec'
require 'database_cleaner'

DatabaseCleaner.strategy = :transaction
DatabaseCleaner.clean_with(:transaction)

class ActiveSupport::TestCase
  include ActiveJob::TestHelper, FactoryBot::Syntax::Methods, AroundEachTest

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # fixtures :users

  # load "#{Rails.root}/db/seeds.rb"

  # Add more helper methods to be used by all tests here...

  # def sign_in(user)
  #   if user.blank? or not user.kind_of?(::User)
  #     return false
  #   end
  #   sign_in user
  # end

end
