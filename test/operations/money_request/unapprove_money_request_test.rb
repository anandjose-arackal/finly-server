# require 'test_helper'
#
# require "#{Rails.root}/app/operations/money_request/unapprove.rb"
# class Unapprove < ActiveSupport::TestCase
#   def setup
#     @manager = User.find_by_email('manager0@finlytest.io')
#     user = User.find(13)
#     @money_request = MoneyRequests::Create.(user,
#         money_request: {items_attributes: [{category_id: Category.first.id,
#                                             amount_attributes: {value: 50, currency_id: Currency.first.id}}]}).money_request
#     MoneyRequests::Submit.(User.find(13), id: @money_request.id)
#     MoneyRequests::Approve.(@manager, id: @money_request.id)
#     @money_request.reload
#   end
#
#   test 'successful approval' do
#     assert_not_equal @manager.id, @money_request.controlling_user.id
#     assert_difference 'MoneyRequestComment.count', 1 do
#       assert_difference 'MoneyRequestTrack.count', 1 do
#         @result = MoneyRequests::Unapprove.(@manager, id: @money_request.id)
#       end
#     end
#     assert @result.money_request.processing?
#     assert @result.money_request.controlling_user.id, @manager.id
#   end
#
# end
