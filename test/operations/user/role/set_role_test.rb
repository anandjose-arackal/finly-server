require 'test_helper'

class SetRoleTest < ActiveSupport::TestCase

  def setup
    @admin = users(:admin)
    @manager = users(:manager)
    @employee = users(:employee)
    @role_updation_params = {"user_roles"=>{"admin"=>"0",
                                            "manager"=>"1",
                                            "finance_manager"=>"1"},
                             "type"=>"role",
                             "view"=>"admin",
                             "id"=>"#{@manager.id}"
                            }
  end

  test "admin can set new roles for a particular use" do
    # changing roles for a manager
    set_role_op = User::Role::Set.new(@admin, @role_updation_params)
    @result = set_role_op.run
    assert @result.success?
    assert @manager.manager?
    assert @manager.employee?
    assert @manager.finance_manager?
    assert_not @manager.admin?

    # changing roles for an employee
    @role_updation_params["id"] = "#{@employee.id}"
    set_role_op = User::Role::Set.new(@admin, @role_updation_params)
    @result = set_role_op.run
    assert @result.success?
    assert @employee.manager?
    assert @employee.employee?
    assert @employee.finance_manager?
    assert_not @employee.admin?
  end

  test "non admins cannot set new roles for users"  do
    # manager trying to change the roles of a user
    @role_updation_params["id"] = "#{@employee.id}"
    set_role_op = User::Role::Set.new(@employee, @role_updation_params)
    begin
      @result = set_role_op.run
    rescue NotAuthorizedException
      @rescued = true
    end
    assert @rescued
    assert @employee.employee?
    assert_not(@employee.manager? || @employee.admin? || @employee.finance_manager?)

  end

end
