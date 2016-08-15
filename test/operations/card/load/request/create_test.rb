require 'test_helper'

class CreateTest < ActiveSupport::TestCase

  def setup
    @user= User.find_by_email('user0@finlytest.io')
    @c = Card.create(ending_number: '1234', proxy: '1234', user: @user)
  end

  test 'successful case' do
    request = Card::Load::Request::Create.new @user, {id: @c.id, card_load_request: {amount_attributes: {value: 50, currency: Currency.first}}}
    assert_difference 'CardLoadRequest.count', 1 do
      assert request.run.present?
    end
    assert_not request.errors.present?
    assert_nil request.card_load_request.note
    assert_not_nil request.card_load_request.controlling_user

    test_note = 'test note'
    request = Card::Load::Request::Create.new @user, {id: @c.id, card_load_request: {amount_attributes: {value: 50, currency: Currency.first},
                                                                                     note: test_note}}
    assert_difference 'CardLoadRequest.count', 1 do
      assert request.run.present?
    end
    assert_not request.errors.present?
    assert_equal request.card_load_request.note, test_note
  end

  test 'Cannot create a request without card' do
    request = Card::Load::Request::Create.new @user, {card_load_request: {amount_attributes: {value: 50, currency: Currency.first}}}
    assert_no_difference 'CardLoadRequest.count' do
      assert_not request.run
    end
    assert request.errors.present?
  end

  test 'Cannot create a request without amount' do
    request = Card::Load::Request::Create.new @user, {id: @c.id, card_load_request: {}}
    assert_no_difference 'CardLoadRequest.count' do
      assert_not request.run
    end
    assert request.errors.present?
  end

  test 'Cannot create a request without user' do
    request = Card::Load::Request::Create.new nil, {id: @c.id, card_load_request: {amount_attributes: {value: 50, currency: Currency.first}}}
    rescued = false
    assert_no_difference 'CardLoadRequest.count' do
      begin
        request.run
      rescue NotAuthorizedException
        rescued = true
      end
    end
    assert rescued
  end

  test 'When a request is created without the user having a finance manager,
    the request stays in processing state till a finance manager takes control of the report and approves it' do

  end

end