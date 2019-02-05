require 'test_helper'
require 'sidekiq/testing'

class RetractTest < ActiveSupport::TestCase

  def setup
    Sidekiq.redis { |conn| conn.flushdb }

    @money_request = MoneyRequest.new
    @owner = User.last
    @manager = User.only_managers.first
    @second_manager = User.only_managers.first
    @finance_manager = User.only_finance_managers.second
    @money_request.stubs(:user).returns(@owner)
  end

  test 'retract from first approver' do
    @money_request.stubs(:tracks => stub(:last => stub(:modified_user => @manager)))
    @money_request.stubs(:associated_users).returns([@manager, @owner])

    response = nil
    event = Event::EMoneyRequests::Retract.new(@owner, money_request: @money_request)
    # Ensure 2 mailers have been triggered
    assert_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size',2 do
      response = event.run
    end
    assert response.success?
    affected_users = event.affected_users
    assert affected_users.include?(@manager)
    assert affected_users.include?(@owner)
  end

  test 'retract from second approver' do
    @money_request.stubs(:tracks => stub(:last => stub(:modified_user => @second_manager)))
    @money_request.stubs(:associated_users).returns([@second_manager, @manager, @owner])

    response = nil
    event = Event::EMoneyRequests::Retract.new(@owner, money_request: @money_request)
    # Ensure 3 mailers have been triggered
    assert_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size',3 do
      response = event.run
    end
    assert response.success?
    affected_users = event.affected_users
    assert affected_users.include?(@second_manager)
    assert affected_users.include?(@manager)
    assert affected_users.include?(@owner)
  end

  test 'behavior when money_request is not passed' do
    response = nil
    event = Event::EMoneyRequests::Retract.new(@finance_manager, money_request: nil)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

  test 'behavior when current user is not passed' do
    response = nil
    event = Event::EMoneyRequests::Retract.new(nil, money_request: @money_request)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

  test 'behavior when current user is not passed and money_request is not passed ' do
    response = nil
    event = Event::EMoneyRequests::Retract.new(nil, money_request: nil)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

end
