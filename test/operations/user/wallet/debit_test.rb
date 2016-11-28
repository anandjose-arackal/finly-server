require 'test_helper'

class DebitTest < ActiveSupport::TestCase

  def setup
    @admin = users(:admin)
    @manager = users(:manager)
    @finance_manager = users(:finance_manager)
    @employee = users(:employee)
  end

  test "successfully debiting money from a user's wallet by admin" do

  end

  test "successful debiting of money from user's wallet by manager" do

  end

  test "successful debiting of money from user's wallet by finance manager" do

  end

  test "invalid parameters for crediting money" do

  end

  test "" do

  end

end