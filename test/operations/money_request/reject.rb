# require 'test_helper'
#
# require "#{Rails.root}/app/operations/money_request/reject.rb"
# class Reject < ActiveSupport::TestCase
#   def setup
#     @manager = User.find_by_email('manager0@finlytest.io')
#     user = User.find(13)
#     @money_request = MoneyRequest::Create.(user,
#         money_request: {items_attributes: [{category_id: Category.first.id,
#                                             amount_attributes: {value: 50, currency_id: Currency.first.id}}]}).money_request
#     MoneyRequest::Submit.(User.find(13), id: @money_request.id)
#     @money_request.reload
#   end
#
#   test 'successful approval' do
#     assert_equal @manager.id, @money_request.controlling_user.id
#     assert_difference 'MoneyRequestComment.count', 1 do
#       assert_difference 'MoneyRequestTrack.count', 1 do
#         @result = MoneyRequest::Reject.(@manager, id: @money_request.id)
#       end
#     end
#     assert @result.money_request.rejected?
#     assert @result.money_request.controlling_user.id, @money_request.user.id
#   end
#
# end