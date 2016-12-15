require 'test_helper'
require 'sidekiq/testing'

class AddCashAdvanceEventTest < ActiveSupport::TestCase

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

  test 'adding new cash advance should send a mailer to receiving user' do
    response = nil
    event = Event::ESettlement::AddCashAdvance.new(@manager, {payment: @payment})
    assert_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size',1 do
      response = event.run
    end
    assert response.success?
    affected_users = event.affected_users
    assert_not affected_users.include?(@manager)
    assert affected_users.include?(@user)
    assert_equal affected_users.size,1
  end

  test 'behavior when payment is not passed for add cash advance' do
    response = nil
    event = Event::ESettlement::AddCashAdvance.new(@finance_manager, payment: nil)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

  test 'behavior when current user is not passed for add cash advance' do
    response = nil
    event = Event::ESettlement::AddCashAdvance.new(nil, payment: @payment)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

  test 'behavior when current user is not passed and payment is not passed for add cash advance' do
    response = nil
    event = Event::ESettlement::AddCashAdvance.new(nil, payment: nil)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

end
