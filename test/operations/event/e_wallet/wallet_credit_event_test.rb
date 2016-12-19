require 'test_helper'
require 'sidekiq/testing'

class WalletCreditEventTest< ActiveSupport::TestCase

  def setup
    Sidekiq.redis { |conn| conn.flushdb }

    @user = User.first
    @manager = User.second
    @amount = Amount.new
    @payment = Payment.new(id: 10000)
    @amount.stubs(:value).returns(100)
    @payment.stubs(:amount => @amount, :initiating_user => @user)
    @payment.stubs(:receiving_user).returns(@user)
  end

  # credit_from_wallet_to_wallet
  # credit_from_virtual_account_to_wallet
  # credit_from_wallet_to_card
  # credit_from_virtual_account_to_card

  test 'crediting from virtual account to wallet should send a mailer to initiating user and receiving user' do
    @payment.stubs(:credit_from_wallet_to_wallet)

    response = nil
    event = Event::EWallet::Credit.new(@manager, {payment: @payment})
    assert_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size',2 do
      response = event.run
    end
    assert response.success?
    affected_users = event.affected_users
    assert affected_users.include?(@manager)
    assert affected_users.include?(@user)
    assert_equal affected_users.size,2
  end

end