require 'test_helper'

require "#{Rails.root}/app/operations/money_request/submit.rb"
class Submit < ActiveSupport::TestCase

  def setup
    @user = User.find(13)
    @money_request = MoneyRequest::Create.(@user, nil).money_request
    @manager = User.find_by_email('manager0@finly.io')
  end

  test 'failed submission as there are no items added' do
    assert_no_difference 'MoneyRequestComment.count' do
      assert_no_difference 'MoneyRequestTrack.count' do
        @result = MoneyRequest::Submit.(@user, id: @money_request.id)
      end
    end
    assert @result.failure?
    assert @money_request.reload.open?
    assert @result.messages[:error].present?
  end

  test 'successful submission' do
    @money_request = MoneyRequest::Create.(@user,
        money_request: {items_attributes: [{category_id: Category.first.id,
                                            amount_attributes: {value: 50, currency_id: Currency.first.id}}]}).money_request
    assert_difference 'MoneyRequestComment.count', 1 do
      assert_difference 'MoneyRequestTrack.count', 1 do
        @result = MoneyRequest::Submit.(@user, id: @money_request.id)
      end
    end
    assert @result.success?
    assert @money_request.reload.processing?
    assert @money_request.controlling_user, @manager
    assert @result.messages[:error].blank?
  end

end