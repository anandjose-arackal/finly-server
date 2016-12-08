require 'test_helper'

class UpdateUserStateTest < ActiveSupport::TestCase

  def setup
    @admin = users(:admin)
    @manager = users(:manager)
    @employee = users(:employee)
    @inactive_employee = users(:inactive_employee)
    @update_state_params = {view: 'admin',
                            active: false,
                            id: @employee.id}
  end

  test "admins can deactivate or activate a user" do
    # mocking the return value for users
    index_users = User.where(id: @employee.id)
    User::Team::Index.stubs(:call).returns(index_users)

    update_state_op = User::Configuration::UpdateState.new(@admin, @update_state_params)
    assert_difference 'User.active.count', -1 do
      @result = update_state_op.run
    end
    assert @result.success?
    assert_not @employee.reload.active?
  end

  test "non admins cannot deactivate or activate a user" do
    # mocking the return value for users
    index_users = User.where(id: @employee.id)
    User::Team::Index.stubs(:call).returns(index_users)

    update_state_op = User::Configuration::UpdateState.new(@manager, @update_state_params)
    assert_no_difference 'User.active.count' do
      begin
        @result = update_state_op.run
      rescue NotAuthorizedException
        @rescued = true
      end
    end
    assert @rescued
    assert @employee.reload.active?
  end

  test "admins can activate a deactivated user" do
    @update_state_params[:id] = @inactive_employee.id
    @update_state_params[:active] = true

    # mocking the return value for users
    index_users = User.where(id: @inactive_employee.id)
    User::Team::Index.stubs(:call).returns(index_users)

    update_state_op = User::Configuration::UpdateState.new(@admin, @update_state_params)
    assert_difference 'User.active.count', 1 do
      @result = update_state_op.run
    end
    assert @result.success?
    assert @inactive_employee.reload.active?
  end

  test "non admins cannot activate a user" do
    @update_state_params[:id] = @inactive_employee.id
    @update_state_params[:active] = true

    # mocking the return value for users
    index_users = User.where(id: @inactive_employee.id)
    User::Team::Index.stubs(:call).returns(index_users)

    update_state_op = User::Configuration::UpdateState.new(@manager, @update_state_params)
    assert_no_difference 'User.active.count' do
      begin
        @result = update_state_op.run
      rescue NotAuthorizedException
        @rescued = true
      end
    end
    assert @rescued
    assert_not @inactive_employee.reload.active?
  end

end