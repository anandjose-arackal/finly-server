require 'test_helper'

class UpdatePasswordTest < ActiveSupport::TestCase

  def setup
    @employee = users(:employee)
    @admin = users(:admin)

    # creating and saving the passwords for two users
    @employee.password = @employee.password_confirmation = "hapitoe007"
    @admin.password = @admin.password_confirmation = "hapitoe007"
    @employee.save
    @admin.save

    @password_change_params = {user: {current_password: "hapitoe007",
                                      password: "password007",
                                      password_confirmation: "password007"
                                     },
                               user_id: @employee.id}
  end

  test "user can successfully update their own password" do
    # checking that the password was indeed saved as "hapitoe007"
    assert @employee.valid_password?("hapitoe007")
    update_password_op = User::Configuration::UpdatePassword.new(@employee, @password_change_params)
    @result = update_password_op.run
    assert @result.success?

    # assert that the password has been changed
    assert @employee.valid_password?("password007")
  end

  test "anyone other than the user itself cannot reset a particular user's password" do
    assert @employee.valid_password?("hapitoe007")
    update_password_op = User::Configuration::UpdatePassword.new(@admin, @password_change_params)
    @result = update_password_op.run
    assert @result.success? # because the operation will update the admin's password

    # assert that the employee's password has NOT been changed
    assert @employee.valid_password?("hapitoe007")
    # assert that the admin's password HAS been changed
    assert @admin.valid_password?("password007")
  end

  test "updating the password without the old password or with invalid old password will fail" do
    @password_change_params[:user][:current_password] = "somethingrandom"

    update_password_op = User::Configuration::UpdatePassword.new(@employee, @password_change_params)
    @result = update_password_op.run
    assert_not @result.success?
    assert_not @result.messages[:error].empty?
    assert @employee.reload.valid_password?("hapitoe007")

    # not giving old password
    @password_change_params[:user][:current_password] = ""
    update_password_op = User::Configuration::UpdatePassword.new(@employee, @password_change_params)
    @result = update_password_op.run
    assert_not @result.success?
    assert_not @result.messages[:error].empty?
    assert @employee.reload.valid_password?("hapitoe007")
  end

  test "password and password confirmation need to match" do
    @password_change_params[:user][:password] = "somethingrandom"

    update_password_op = User::Configuration::UpdatePassword.new(@employee, @password_change_params)
    @result = update_password_op.run
    assert_not @result.success?
    assert_not @result.messages[:error].empty?
    assert @employee.reload.valid_password?("hapitoe007")
  end

end