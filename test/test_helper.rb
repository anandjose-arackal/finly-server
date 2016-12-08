ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha/mini_test'
require 'sidekiq/testing'

class ActiveSupport::TestCase
  include ActiveJob::TestHelper
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :users

  # load "#{Rails.root}/db/seeds.rb"

  # Add more helper methods to be used by all tests here...

  # def sign_in(user)
  #   if user.blank? or not user.kind_of?(::User)
  #     return false
  #   end
  #   sign_in user
  # end

end
