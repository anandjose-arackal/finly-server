require 'test_helper'

class AutoSubmitConfigurationUpdateTest < ActiveSupport::TestCase

  def setup
    @current_user = users(:employee)
    @updating_user = users(:manager)
  end

  test 'Current User, User ID and update params need to be passed to perform the update' do
    result = User::Configuration::AutoSubmit::Update.(@current_user, {user: {enabled: true, period_id: Period.id_for(:day)}, view: 'admin'})
    assert_not result.success?

    exception_caught = false
    begin
      User::Configuration::AutoSubmit::Update.(nil, {user: {id: @updating_user.id, enabled: true, period_id: Period.id_for(:day)}, view: 'admin'})
    rescue NotAuthorizedException
      exception_caught = true
    end
    assert exception_caught

    result = User::Configuration::AutoSubmit::Update.(@current_user, {user: {id: @updating_user.id}, view: 'admin'})
    assert_not result.success?
  end

  test "Only admin's can update auto_submit" do
    user = User.fourth
    assert_not user.admin?
    exception_caught = false
    begin
      User::Configuration::AutoSubmit::Update.(user, user: {id: @updating_user.id, enabled: true, period_id: Period.id_for(:day)}, view: 'admin')
    rescue NotAuthorizedException
      exception_caught = true
    end
    assert exception_caught
  end

  test 'Successful update' do
    assert_not @updating_user.auto_submit_config.enabled
    result = User::Configuration::AutoSubmit::Update.(@current_user, user: {id: @updating_user.id, enabled: true, period_id: Period.id_for(:day)}, view: 'admin')
    assert result.success?
    assert @updating_user.reload.auto_submit_config.enabled
  end

end