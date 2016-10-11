require 'test_helper'

class TakeControlTest < ActiveSupport::TestCase

  def setup
    @user= User.find_by_email('user0@finlytest.io')
    @card = Card.create(ending_number: '1234', proxy: '1234', user: @user)
    @request = MoneyRequest::Create.(@user, {id: @card.id, money_request:
        {amount_attributes: {value: 50, currency_id: Currency.first.id}}}).money_request
  end

  test 'successful take_control' do
    user = User.first
    assert @request.processing?
    assert_not_equal @request.controlling_user, user
    assert_difference 'MoneyRequestComment.count', 1 do
      assert_difference 'MoneyRequestTrack.count', 1 do
        assert MoneyRequest::TakeControl.(user, id: @request.id).present?
      end
    end
    assert @request.reload.processing?
    assert_equal @request.controlling_user, user
  end

  test 'only company admins and policy admins can take control of the report' do

  end

end