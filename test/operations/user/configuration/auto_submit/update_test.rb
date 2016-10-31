require 'test_helper'

class UpdateTest < ActiveSupport::TestCase

  def setup
    @current_user = User.first
    @updating_user = User.last
  end

  test 'Current User, User ID and update params need to be passed to perform the update' do
    result = User::Configuration::AutoSubmit::Update.(@current_user, {user: {enabled: true, default_category_id: 1, period_id: Period.id_for(:day)}, view: 'admin'})
    assert_not result.success?

    exception_caught = false
    begin
      User::Configuration::AutoSubmit::Update.(nil, {user: {id: @updating_user.id, enabled: true, default_category_id: 1, period_id: Period.id_for(:day)}, view: 'admin'})
    rescue NotAuthorizedException
      exception_caught = true
    end
    assert exception_caught

    result = User::Configuration::AutoSubmit::Update.(@current_user, {user: {id: @updating_user.id}, view: 'admin'})
    assert_not result.success?
  end

  test "Cannot assign categories which do not belong to current user's company" do
    exception_caught = false
    begin
      User::Configuration::AutoSubmit::Update.(@current_user, user: {id: @updating_user.id, enabled: true, default_category_id: Company.second.categories.first.id, period_id: Period.id_for(:day)}, view: 'admin')
    rescue NotAuthorizedException
      exception_caught = true
    end
    assert exception_caught
  end

  test "Only admin's can update auto_submit" do
    user = User.fourth
    assert_not user.admin?
    exception_caught = false
    begin
      User::Configuration::AutoSubmit::Update.(user, user: {id: @updating_user.id, enabled: true, default_category_id: Company.second.categories.first.id, period_id: Period.id_for(:day)}, view: 'admin')
    rescue NotAuthorizedException
      exception_caught = true
    end
    assert exception_caught
  end

  test 'Successful update' do
    result = User::Configuration::AutoSubmit::Update.(@current_user, user: {id: @updating_user.id, enabled: true, default_category_id: 1, period_id: Period.id_for(:day)}, view: 'admin')
    assert result.success?
  end

end