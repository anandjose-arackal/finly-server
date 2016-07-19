require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  test "should get organization_account" do
    get :organization_account
    assert_response :success
  end

end
