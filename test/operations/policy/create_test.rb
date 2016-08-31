require 'test_helper'
require 'helpers/report_operation_test_helper'

class CreateTest < ActiveSupport::TestCase

  def setup
    @admin = User.first
    @manager = User.find_by(email: 'manager2@finlytest.io')
    @finance_manager = User.find_by(email: 'finance1@finlytest.io')
  end

  test "successfully creating a policy" do
    create_op = Policy::Create.new(@admin, name: "Test")
    assert_difference 'Policy.count', 1 do
      @policy = create_op.run
    end
    assert @policy
    assert_equal "Test", @policy.name
    assert_equal @admin.id, @policy.admins.first.id
    assert_equal 1, @policy.users.count
  end

  test "only admins can create policies within a company" do
    create_op = Policy::Create.new(@manager, name: "Test")
    assert_no_difference 'Policy.count', 1 do
      begin
        @result = create_op.run
      rescue
        @rescued = true
      end
    end
    assert @rescued

    # checking finance manager as well
    create_op = Policy::Create.new(@finance_manager, name: "Test")
    assert_no_difference 'Policy.count', 1 do
      begin
        @result = create_op.run
      rescue
        @rescued = true
      end
    end
    assert @rescued

  end
end