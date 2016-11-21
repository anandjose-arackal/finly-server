require 'test_helper'
require 'sidekiq/testing'

class ShowTest < ActiveSupport::TestCase

  def setup
    @user = User.first
  end

  test 'not passing policy should give users default company mapping' do
    
  end

end
