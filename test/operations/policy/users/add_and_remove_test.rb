require 'test_helper'

class AddAndRemoveTest < ActiveSupport::TestCase

  def setup
    @admin = users(:admin)
    @employee = users(:employee)
    @manager = users(:manager)
    @finance_manager = users(:finance_manager)
    @policy = Policy::Create.(@admin, name: "Testing...").policies.order(created_at: :desc).first
  end


  test "admins can add users to a policy" do

    # assert that the policy has been created
    assert @policy

    # adding a single user
    add_user_op = Policy::Users::AddUser.new(@admin, {policy_id: @policy.id, user_id: "#{@manager.id}"})
    assert_difference '@policy.users.count', 1 do
      @result = add_user_op.run
    end
    assert @result.success?
    @policy = @result.policy
    assert @policy
    assert @policy.users.find_by(id: @manager.id)

    # adding multiple users to the policy
    add_user_op = Policy::Users::AddUser.new(@admin, {policy_id: @policy.id, user_id: "#{@employee.id},#{@finance_manager.id}"})
    assert_difference '@policy.users.count', 2 do
      @result = add_user_op.run
    end
    assert @result.success?
    @policy = @result.policy
    assert @policy
    assert @policy.users.find_by(id: @employee.id)
    assert @policy.users.find_by(id: @finance_manager.id)
  end

  test "policy admins can also add people to a policy" do
    # mocking the return value of the index presenter
    index_presenter = Policy::Index::IndexPresenter.new(@admin, {policies: Policy.where(id: @policy.id)})
    Policy::Index.stubs(:call).returns(index_presenter)

    # making the manager a policy admin temporarily
    @manager.stubs(:policy_admin?).returns(true)
    @manager.stubs(:policy_admin?).with(@policy).returns(true)

    # adding a single user
    add_user_op = Policy::Users::AddUser.new(@admin, {policy_id: @policy.id, user_id: "#{@manager.id}"})
    assert_difference '@policy.users.count', 1 do
      @result = add_user_op.run
    end
    assert @result.success?
    @policy = @result.policy
    assert @policy
    assert @policy.users.find_by(id: @manager.id)

    # adding multiple users to the policy
    add_user_op = Policy::Users::AddUser.new(@admin, {policy_id: @policy.id, user_id: "#{@employee.id},#{@finance_manager.id}"})
    assert_difference '@policy.users.count', 2 do
      @result = add_user_op.run
    end
    assert @result.success?
    @policy = @result.policy
    assert @policy
    assert @policy.users.find_by(id: @employee.id)
    assert @policy.users.find_by(id: @finance_manager.id)
  end

  test "non-policy admins cannot add another user" do
    assert @policy

    # trying for a manager
    add_user_op = Policy::Users::AddUser.new(@manager, {policy_id: @policy.id, user_id: @employee.id})
    assert_no_difference '@policy.users.count' do
      begin
        @policy = add_user_op.run
      rescue
        @rescued = true
      end
    end
    assert @rescued
    assert_not @policy.users.find_by(id: @employee.id)

    # trying for a finance manager
    add_user_op = Policy::Users::AddUser.new(@finance_manager, {policy_id: @policy.id, user_id: @employee.id})
    assert_no_difference '@policy.users.count' do
      begin
        @policy = add_user_op.run
      rescue
        @rescued = true
      end
    end
    assert @rescued
    assert_not @policy.users.find_by(id: @employee.id)
  end

  test "admins can remove users from a policy" do
    assert @policy

    # adding three particular users to the policy who will be removed later
    @result = Policy::Users::AddUser.(@admin, {policy_id: @policy.id, user_id: "#{@manager.id},#{@finance_manager.id},#{@employee.id}"})
    assert @result.policy.users.find_by(id: @manager.id)
    assert @result.policy.users.find_by(id: @finance_manager.id)
    assert @result.policy.users.find_by(id: @employee.id)

    # removing a single user
    add_user_op = Policy::Users::RemoveUser.new(@admin, {policy_id: @policy.id, user_id: "#{@manager.id}"})
    assert_difference '@policy.users.count', -1 do
      @result = add_user_op.run
    end
    assert @result.success?
    @policy = @result.policy
    assert @policy
    assert_not @policy.users.find_by(id: @manager.id)

    # removing multiple users
    add_user_op = Policy::Users::RemoveUser.new(@admin, {policy_id: @policy.id, user_id: "#{@finance_manager.id}, #{@employee.id}"})
    assert_difference '@policy.users.count', -2 do
      @result = add_user_op.run
    end
    assert @result.success?
    @policy = @result.policy
    assert @policy
    assert_not @policy.users.find_by(id: @finance_manager.id)
    assert_not @policy.users.find_by(id: @employee.id)
  end


  test "policy admins can also remove users from a policy" do
    assert @policy
    # adding three particular users to the policy who will be removed later
    @result = Policy::Users::AddUser.(@admin, {policy_id: @policy.id, user_id: "#{@manager.id},#{@finance_manager.id},#{@employee.id}"})
    assert @result.policy.users.find_by(id: @manager.id)
    assert @result.policy.users.find_by(id: @finance_manager.id)
    assert @result.policy.users.find_by(id: @employee.id)

    # mocking policy index to include the current policy
    index_presenter = Policy::Index::IndexPresenter.new(@admin, {policies: Policy.where(id: @policy.id)})
    Policy::Index.stubs(:call).returns(index_presenter)

    # making the manager a policy admin temporarily
    @manager.stubs(:policy_admin?).returns(true)
    @manager.stubs(:policy_admin?).with(@policy).returns(true)
    # stubbing policy.admins as an array containing two elements
    Policy.any_instance.stubs(:admins).returns([1,2])

    # removing a single user
    remove_user_op = Policy::Users::RemoveUser.new(@manager, {policy_id: @policy.id, user_id: "#{@employee.id}"})
    assert_difference '@policy.users.count', -1 do
      @result = remove_user_op.run
    end
    assert @result.success?
    @policy = @result.policy
    assert_not @policy.users.find_by(id: @employee.id)

    # removing multiple users
    remove_user_op = Policy::Users::RemoveUser.new(@manager, {policy_id: @policy.id, user_id: "#{@admin.id},#{@finance_manager.id}"})
    assert_difference '@policy.users.count', -2 do
      @result = remove_user_op.run
    end
    assert @result.success?
    @policy = @result.policy
    assert_not @policy.users.find_by(id: @admin.id)
    assert_not @policy.users.find_by(id: @finance_manager.id)
  end


  test "non policy admins cannot remove a user from a policy" do
    assert @policy

    # adding three particular users to the policy who will be removed later
    @result = Policy::Users::AddUser.(@admin, {policy_id: @policy.id, user_id: "#{@manager.id},#{@finance_manager.id},#{@employee.id}"})
    assert @result.policy.users.find_by(id: @manager.id)
    assert @result.policy.users.find_by(id: @finance_manager.id)
    assert @result.policy.users.find_by(id: @employee.id)

    # trying for manager
    remove_user_op = Policy::Users::RemoveUser.new(@manager, {policy_id: @policy.id, user_id: "#{@employee.id}"})
    assert_no_difference '@policy.users.count' do
      begin
        @policy = remove_user_op.run
      rescue
        @rescued = true
      end
    end
    assert @rescued
    assert @policy.users.find_by(id: @employee.id)

    remove_user_op = Policy::Users::RemoveUser.new(@finance_manager, {policy_id: @policy.id, user_id: "#{@manager.id}"})
    assert_no_difference '@policy.users.count' do
      begin
        @policy = remove_user_op.run
      rescue
        @rescued = true
      end
    end
    assert @rescued
    assert @policy.users.find_by(id: @manager.id)
  end


  test "cannot remove the last admin from a policy" do
    assert @policy

    # adding another @manager user as an admin
    add_user_op = Policy::Users::AddUser.new(@admin, {policy_id: @policy.id, user_id: "#{@manager.id}", admin: true})
    @policy = add_user_op.run.policy
    assert_equal 2, @policy.users.count
    assert_equal 2, @policy.admins.count
    assert @manager.policy_admin?(@policy)

    # adding another user just for kicks
    add_user_op = Policy::Users::AddUser.new(@manager, {policy_id: @policy.id, user_id: "#{@employee.id}"})
    @policy = add_user_op.run.policy
    assert_equal 3, @policy.users.count
    assert_equal 2, @policy.admins.count

    remove_user_op = Policy::Users::RemoveUser.new(@manager, {policy_id: @policy.id, user_id: "#{@admin.id}"})
    assert_difference '@policy.users.count', -1 do
      @result = remove_user_op.run
    end
    @policy = @result.policy
    assert @result.success?
    assert_not @policy.users.find_by(id: @admin.id)
    assert_equal 1, @policy.admins.count # checking that there's only one admin left

    # removing the last admin from the policy should fail
    remove_user_op = Policy::Users::RemoveUser.new(@admin, {policy_id: @policy.id, user_id: "#{@manager.id}"})
    assert_no_difference '@policy.users.count' do
      begin
        remove_user_op.run
      rescue
        @rescued = true
      end
    end
    assert @rescued
    assert @policy.users.find_by(id: @manager.id)
  end

end