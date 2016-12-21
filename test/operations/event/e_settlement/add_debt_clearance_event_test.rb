require 'test_helper'
require 'sidekiq/testing'

class AddDebtClearanceEventTest < ActiveSupport::TestCase

  def setup
    Sidekiq.redis { |conn| conn.flushdb }

    @user = User.first
    @manager = User.second
    @amount = Amount.new
    @payment = Payment.new(id: 10000)
    @amount.stubs(:value).returns(100)
    @payment.stubs(:amount => @amount, :initiating_user => @user)
    @payment.stubs(:receiving_user).returns(@user)
    @payment.stubs(:initiating_user).returns(@manager)
  end

  test 'adding new debt clearance should send a mailer to receiving user' do
    response = nil
    event = Event::ESettlement::AddDebtClearance.new(@manager, {payment: @payment})
    assert_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size',1 do
      response = event.run
    end
    assert response.success?
    affected_users = event.affected_users
    assert_not affected_users.include?(@manager)
    assert affected_users.include?(@user)
    assert_equal affected_users.size,1
  end

  test 'behavior when payment is not passed for debt clearance' do
    response = nil
    event = Event::ESettlement::AddDebtClearance.new(@finance_manager, payment: nil)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

  test 'behavior when current user is not passed for debt clearance' do
    response = nil
    event = Event::ESettlement::AddDebtClearance.new(nil, payment: @payment)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

  test 'behavior when current user is not passed and payment is not passed for debt clearance' do
    response = nil
    event = Event::ESettlement::AddDebtClearance.new(nil, payment: nil)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

end
