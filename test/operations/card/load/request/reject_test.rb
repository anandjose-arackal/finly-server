require 'test_helper'

class RejectTest < ActiveSupport::TestCase

  def setup
    @user= User.find_by_email('user0@finlytest.io')
    @card = Card.create(ending_number: '1234', proxy: '1234', user: @user)
    @request = Card::Load::Request::Create.(@user, {id: @card.id, card_load_request: {amount_attributes: {value: 50, currency_id: Currency.first.id}}}).card_load_request
  end

  test 'successful reject' do
    assert @request.processing?
    user = @request.controlling_user
    assert_difference 'CardLoadRequestComment.count', 1 do
      assert_difference 'CardLoadRequestTrack.count', 1 do
        assert Card::Load::Request::Reject.(user, id: @request.id).present?
      end
    end
    assert @request.reload.rejected?
    assert_equal @request.controlling_user, @request.user
  end

  test 'successful reject to user' do
    assert Card::Load::Request::Approve.(@request.controlling_user, id: @request.id)
    @request.reload
    assert @request.processing?
    user = @request.controlling_user
    assert_equal user.email, 'manager1@finlytest.io'
    to_user = User.find_by_email 'manager0@finlytest.io'
    assert_difference 'CardLoadRequestComment.count', 1 do
      assert_difference 'CardLoadRequestTrack.count', 1 do
        assert Card::Load::Request::Reject.(user, id: @request.id, reject_to: to_user.id).present?
      end
    end
    assert @request.reload.processing?
    assert_equal @request.controlling_user, to_user
  end

  test 'Can only be rejected to users who have approved the request or the owner' do
    assert @request.processing?
    user = @request.controlling_user
    to_user = User.find_by_email('manager1@finlytest.io')
    rescued = false
    assert_no_difference 'CardLoadRequestComment.count' do
      assert_no_difference 'CardLoadRequestTrack.count' do
        begin
          Card::Load::Request::Reject.(user, id: @request.id, reject_to: to_user.id)
        rescue
          rescued = true
        end
      end
    end
    assert rescued
    assert @request.reload.processing?
    assert_equal @request.controlling_user, user
  end

  test 'Can only be rejected by controlling user' do
    assert @request.processing?
    user = @request.controlling_user
    rejecting_user = User.find_by_email('manager1@finlytest.io')
    assert_not_equal user, rejecting_user
    rescued = false
    assert_no_difference 'CardLoadRequestComment.count' do
      assert_no_difference 'CardLoadRequestTrack.count' do
        begin
          Card::Load::Request::Reject.(rejecting_user, id: @request.id)
        rescue
          rescued = true
        end
      end
    end
    assert rescued
    assert @request.reload.processing?
    assert_equal @request.controlling_user, user
  end

end