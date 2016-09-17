require 'test_helper'

require "#{Rails.root}/lib/operations/money_request/update.rb"
class Update < ActiveSupport::TestCase

  def setup
    @user = User.find(13)
    @money_request = MoneyRequest::Create.(@user, nil).money_request
    @manager = User.find_by_email('manager0@finly.io')
  end

  test 'successful update' do
    name = 'Hahaha'
    total_amount = @money_request.total_amount
    added_amount = 60
    assert_not_equal @money_request.name, name
    @result = MoneyRequest::Update.(@user, id: @money_request.id,
        money_request: {name: name, items_attributes: [{category_id: 2, amount_attributes: {value: added_amount, currency_id: 1}}]})
    assert @result.success?
    assert_equal @result.money_request.reload.name, name
    assert_equal @result.money_request.total_amount, total_amount+added_amount
  end

end