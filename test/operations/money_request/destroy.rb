require 'test_helper'

require "#{Rails.root}/app/operations/money_request/destroy.rb"
class Destroy < ActiveSupport::TestCase
  def setup
    @user = User.find(13)
    @money_request = MoneyRequest::Create.(@user,
        money_request: {items_attributes: [{category_id: Category.first.id,
                                            amount_attributes: {value: 50, currency_id: Currency.first.id}}]}).money_request
  end

  test 'successful destroy' do
    id = @money_request.id
    @result = MoneyRequest::Destroy.(@user, id: id)
    assert @result.success?
    assert MoneyRequest.find_by(id: id).nil?
  end

end