require 'test_helper'

require "#{Rails.root}/app/operations/money_request/retract.rb"
class Retract < ActiveSupport::TestCase
  def setup
    @user = User.find(13)
    @money_request = MoneyRequest::Create.(@user,
        money_request: {items_attributes: [{category_id: Category.first.id,
                                            amount_attributes: {value: 50, currency_id: Currency.first.id}}]}).money_request
    MoneyRequest::Submit.(@user, id: @money_request.id)
    @money_request.reload
  end

  test 'successful retract' do
    assert_not_equal @user.id, @money_request.controlling_user.id
    assert_difference 'MoneyRequestComment.count', 1 do
      assert_difference 'MoneyRequestTrack.count', 1 do
        @result = MoneyRequest::Retract.(@user, id: @money_request.id)
      end
    end
    assert @result.money_request.retracted?
    assert @result.money_request.controlling_user.id, @user.id
  end

end