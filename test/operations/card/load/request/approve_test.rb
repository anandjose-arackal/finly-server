require 'test_helper'

class ApproveTest < ActiveSupport::TestCase

  def setup
    @user= User.find_by_email('user0@finlytest.io')
    @c = Card.create(ending_number: '1234', proxy: '1234', user: @user)
    @request = MoneyRequest::Create.(@user, {id: @c.id, money_request: {amount_attributes: {value: 50, currency_id: Currency.first.id}}}).money_request
  end

  test 'successful approve' do
    # Once approved the load request would be forwarded to the next manager in the chain
    # Once the final approver in the chain approves, the amount is credited to users card
    assert @request.processing?
    user = @request.controlling_user
    next_user = User::Team::Review::NextReviewer.(@request)
    assert_difference 'MoneyRequestTrack.count', 1 do
      assert MoneyRequest::Approve.(user, id: @request.id).present?
    end
    assert @request.reload.processing?
    assert_equal @request.controlling_user, next_user
  end

  test 'Can only be approved by controlling user' do
    assert @request.processing?
    user = User.find_by_email('manager1@finlytest.io')
    assert_not_equal user.email, 'manager0@finlytest.io'
    rescued = false
    assert_no_difference 'MoneyRequestTrack.count' do
      begin
        assert_not MoneyRequest::Approve.(user, id: @request.id).present?
      rescue
        rescued = true
      end
    end
    assert rescued
    assert @request.reload.processing?
    assert_not_equal @request.controlling_user, user
    assert_equal @request.controlling_user.email, 'manager0@finlytest.io'
  end

end