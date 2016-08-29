require 'test_helper'
require '../../../../../app/operations/card/load/request/create'

class CreateTest < ActiveSupport::TestCase

  def setup
    @user= User.find_by_email('user0@finlytest.io')
    @c = Card.create(ending_number: '1234', proxy: '1234', user: @user)
  end

  test 'successful case' do
    request = Card::Load::Request::Create.new @user, {id: @c.id, card_load_request: {amount_attributes: {value: 50, currency_id: Currency.first.id}}}
    assert_difference 'CardLoadRequestComment.count', 1 do
      assert_difference 'CardLoadRequest.count', 1 do
        assert request.run.present?
      end
    end
    assert_not request.errors.present?
    assert_nil request.card_load_request.note
    assert_not_nil request.card_load_request.controlling_user

    test_note = 'test note'
    request = Card::Load::Request::Create.new @user, {id: @c.id, card_load_request: {amount_attributes: {value: 50, currency_id: Currency.first.id},
                                                                                     note: test_note}}
    assert_difference 'CardLoadRequestComment.count', 1 do
      assert_difference 'CardLoadRequest.count', 1 do
        assert request.run.present?
      end
    end
    assert_not request.errors.present?
    assert_equal request.card_load_request.note, test_note
  end

  test 'Cannot create a request without card' do
    request = Card::Load::Request::Create.new @user, {card_load_request: {amount_attributes: {value: 50, currency_id: Currency.first.id}}}
    assert_no_difference 'CardLoadRequestComment.count' do
      assert_no_difference 'CardLoadRequest.count' do
        assert_not request.run
      end
    end
    assert request.errors.present?
  end

  test 'Cannot create a request without amount' do
    request = Card::Load::Request::Create.new @user, {id: @c.id, card_load_request: {}}
    assert_no_difference 'CardLoadRequestComment.count' do
      assert_no_difference 'CardLoadRequest.count' do
        assert_not request.run
      end
    end
    assert request.errors.present?
  end

  test 'Cannot create a request without user' do
    request = Card::Load::Request::Create.new nil, {id: @c.id, card_load_request: {amount_attributes: {value: 50, currency_id: Currency.first}}}
    rescued = false
    assert_no_difference 'CardLoadRequestComment.count' do
      assert_no_difference 'CardLoadRequest.count' do
        begin
          request.run
        rescue NotAuthorizedException
          rescued = true
        end
      end
    end
    assert rescued
  end

  test 'When a request is created without the user having a finance manager,
    the request stays in processing state till a finance manager takes control of the report and approves it' do

  end

end