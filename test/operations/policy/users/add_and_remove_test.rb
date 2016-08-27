require 'test_helper'

class AddAndRemoveTest < ActiveSupport::TestCase

  def setup
    @admin = User.first
    @policy = Policy::Create.new(@admin, name: "Test").run
    @employee = User.find_by(email: 'user0@finlytest.io')
    @manager = User.find_by(email: 'manager0@finlytest.io')
    @second_manager = User.find_by(email: 'manager1@finlytest.io')
    @random_employee = User.find_by(email: 'user1@finlytest.io')
    add_user_op = Policy::Users::AddUser.new(@admin, {policy_id: @policy.id, added_user_id: @employee.id, admin: true})
    @policy = add_user_op.run
    @policy = Policy::Users::AddUser.new(@admin, {policy_id: @policy.id, added_user_id: @random_employee.id}).run
  end

  test "Only admins or policy admins can add users to a policy" do
    assert @policy
    add_user_op = Policy::Users::AddUser.new(@admin, {policy_id: @policy.id, added_user_id: @manager.id})
    assert_difference '@policy.users.count', 1 do
      @policy = add_user_op.run
    end
    assert @policy
    assert @policy.users.find_by(id: @manager.id)

    # policy admin adding a new user
    add_user_op = Policy::Users::AddUser.new(@employee, {policy_id: @policy.id, added_user_id: @second_manager.id})
    assert_difference '@policy.users.count', 1 do
      @policy = add_user_op.run
    end
    assert @policy
    assert @policy.users.find_by(id: @second_manager.id)
  end

  test "non-policy admins cannot add another user" do
    assert @policy
    add_user_op = Policy::Users::AddUser.new(@manager, {policy_id: @policy.id, added_user_id: @second_manager.id})
    assert_no_difference '@policy.users.count' do
      begin
        @policy = add_user_op.run
      rescue
        @rescued = true
      end
    end
    assert @rescued
    assert_not @policy.users.find_by(id: @second_manager.id)
  end

  test "only policy admins can remove users from the policy" do
    assert @policy
    remove_user_op = Policy::Users::RemoveUser.new(@admin, {policy_id: @policy.id, removed_user_id: @random_employee.id})
    assert_difference '@policy.users.count', -1 do
      @policy = remove_user_op.run
    end
    assert @policy
    assert_not @policy.users.find_by(id: @manager.id)

    # adding the user back to the policy
    @policy = Policy::Users::AddUser.new(@admin, {policy_id: @policy.id, added_user_id: @random_employee.id}).run

    # policy admin removing a user
    remove_user_op = Policy::Users::RemoveUser.new(@employee, {policy_id: @policy.id, removed_user_id: @random_employee.id})
    assert_difference '@policy.users.count', -1 do
      @policy = remove_user_op.run
    end
    assert @policy
    assert_not @policy.users.find_by(id: @manager.id)
  end

  test "non policy admins cannot remove a user from a policy" do
    assert @policy
    remove_user_op = Policy::Users::RemoveUser.new(@manager, {policy_id: @policy.id, added_user_id: @second_manager.id})
    assert_no_difference '@policy.users.count' do
      begin
        @policy = remove_user_op.run
      rescue
        @rescued = true
      end
    end
    assert @rescued
    assert_not @policy.users.find_by(id: @second_manager.id)
  end

  test "cannot remove the last admin from a policy" do
    assert @policy
    remove_user_op = Policy::Users::RemoveUser.new(@admin, {policy_id: @policy.id, removed_user_id: @employee.id})
    assert_difference '@policy.users.count', -1 do
      @policy = remove_user_op.run
    end
    assert @policy
    assert_not @policy.users.find_by(id: @employee.id)
    assert_equal 1, @policy.admins.count # checking that there's only one admin left

    # removing the last admin from the policy should fail
    remove_user_op = Policy::Users::RemoveUser.new(@admin, {policy_id: @policy.id, added_user_id: @admin.id})
    assert_no_difference '@policy.users.count' do
      begin
        @policy = remove_user_op.run
      rescue
        @rescued = true
      end
    end
    assert @rescued
    assert_not @policy.users.find_by(id: @second_manager.id)

  end
end