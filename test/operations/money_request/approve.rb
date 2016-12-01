# require 'test_helper'
#
# require "#{Rails.root}/app/operations/money_request/approve.rb"
# class Approve < ActiveSupport::TestCase
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
#         @result = MoneyRequest::Approve.(@manager, id: @money_request.id)
#       end
#     end
#     # debugger
#     assert @result.money_request.processing?
#     assert @result.money_request.controlling_user.id, User.find_by_email('manager1@finlytest.io').id
#   end
#
# end