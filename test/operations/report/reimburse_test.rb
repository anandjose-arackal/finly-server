class ReimburseTest < ActiveSupport::TestCase


  def setup
    @employee = User.find_by(email: 'user0@finlytest.io')
    @manager = User.find_by(email: 'manager0@finlytest.io')
    @second_manager = User.find_by(email: 'manager1@finlytest.io')
  end


end