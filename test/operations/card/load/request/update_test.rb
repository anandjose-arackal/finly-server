require 'test_helper'

class UpdateTest < ActiveSupport::TestCase

  def setup
    @c = Card.create(ending_number: '1234', proxy: '1234', user: User.last)
    @request = Card::Load::Request::Create.(User.last, {id: @c.id, card_load_request: {amount_attributes: {value: 50, currency_id: Currency.first.id}}}).card_load_request
  end

  test 'Successful Note Update' do
    note = 'test note 3123'
    assert_not_equal @request.note, note
    assert_difference 'CardLoadRequestComment.count', 1 do
      assert Card::Load::Request::Update.(@request.controlling_user, {id: @request.id, card_load_request: {note: note}})
    end
    assert_equal @request.reload.note, note
  end

  test 'Successful Amount Update' do
    assert_not_equal @request.amount.value, 100
    assert_difference 'CardLoadRequestComment.count', 1 do
      assert Card::Load::Request::Update.(@request.controlling_user, {id: @request.id, card_load_request: {amount_attributes: {id: @request.amount.id, value: 100}}})
    end
    assert_equal @request.reload.amount.value, 100
  end

  test 'Cannot update without passing any fields' do
    assert_no_difference 'CardLoadRequestComment.count' do
      assert_not Card::Load::Request::Update.(@request.controlling_user, {id: @request.id})
    end
  end

  test 'Cannot update without passing request id' do
    assert_not_equal @request.amount.value, 100
    assert_no_difference 'CardLoadRequestComment.count' do
      assert_not Card::Load::Request::Update.(@request.controlling_user, {card_load_request: {amount_attributes: {id: @request.amount.id, value: 100}}})
    end
    assert_equal @request.reload.amount.value, 50
  end

  test 'Cannot update without passing user' do
    rescued = false
    assert_no_difference 'CardLoadRequestComment.count' do
      begin
        assert_not Card::Load::Request::Update.(nil, {card_load_request: {amount_attributes: {id: @request.amount.id, value: 100}}})
      rescue NotAuthorizedException
        rescued = true
      end
    end
    assert rescued
  end

  test 'only controlling user can update' do
    assert_no_difference 'CardLoadRequestComment.count' do
      assert_not Card::Load::Request::Update.(User.last, {card_load_request: {amount_attributes: {id: @request.amount.id, value: 100}}})
    end
  end

  test 'Can be edited only when retracted' do

  end

end