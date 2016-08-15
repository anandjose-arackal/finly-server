require 'test_helper'

class RetractTest < ActiveSupport::TestCase

  def setup
    @user= User.find_by_email('user0@finlytest.io')
    @c = Card.create(ending_number: '1234', proxy: '1234', user: @user)
    @request = Card::Load::Request::Create.(@user, {id: @c.id, card_load_request: {amount_attributes: {value: 50, currency: Currency.first}}}).card_load_request
  end

  test 'successful retract' do
    assert @request.processing?
    assert @request.user.id, @user.id
    assert_difference 'CardLoadRequestTrack.count', 1 do
      assert Card::Load::Request::Retract.(@user, id: @request.id)
    end
    assert @request.reload.retracted?
    assert_equal @request.controlling_user.id, @user.id
  end

  test 'can only be retracted when in processing state' do
    assert @request.processing?
    assert Card::Load::Request::Retract.(@user, id: @request.id)
    assert @request.reload.retracted?
    rescued = false
    begin
      Card::Load::Request::Retract.(@user, id: @request.id)
    rescue
      rescued = true
    end
    assert rescued
  end

  test 'only owners can retract requests' do
    assert @request.processing?
    assert @request.user.id, @user.id
    rescued = false
    begin
      Card::Load::Request::Retract.(User.last, id: @request.id)
    rescue
      rescued = true
    end
    assert @request.reload.processing?
    assert_not_equal @request.controlling_user, @user
    assert rescued
  end

end