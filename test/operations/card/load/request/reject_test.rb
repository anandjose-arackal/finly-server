require 'test_helper'

class RejectTest < ActiveSupport::TestCase
  
  def setup
    @user= User.find_by_email('user0@finlytest.io')
    @card = Card.create(ending_number: '1234', proxy: '1234', user: @user)
    @request = Card::Load::Request::Create.(@user, {id: @card.id, card_load_request: {amount_attributes: {value: 50, currency: Currency.first}}}).card_load_request
  end
  
  test 'successful reject' do
    
  end

  test 'Can only be rejected to users who have approved the request or the owner' do

  end
  
end