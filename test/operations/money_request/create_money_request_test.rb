# require 'test_helper'
#
# class Approve < ActiveSupport::TestCase
#
#   def setup
#     @user = User.find(13)
#   end
#
#   test 'Creating new request' do
#     assert_difference 'MoneyRequest.count', 1 do
#       @result = MoneyRequests::Create.(@user, nil)
#     end
#     assert @result.success?
#
#     name = 'Test Dummy Name'
#     assert_difference 'MoneyRequest.count', 1 do
#       @result = MoneyRequests::Create.(@user, money_request: {name: name})
#     end
#     assert @result.success?
#     assert_equal @result.money_request.name, name
#     assert @result.money_request.open?
#
#     name = 'Test Dummy Name'
#     policy_id = @user.policies.last.id
#     assert_difference 'MoneyRequest.count', 1 do
#       @result = MoneyRequests::Create.(@user,
#           money_request: {name: name, policy_id: policy_id,
#                           items_attributes: [{category_id: Category.first.id,
#                                               amount_attributes: {value: 50, currency_id: Currency.first.id}}]})
#     end
#     assert @result.success?
#     assert_equal @result.money_request.name, name
#     assert_equal @result.money_request.policy_id, policy_id
#     assert_equal @result.money_request.total_amount, 50
#   end
#
# end