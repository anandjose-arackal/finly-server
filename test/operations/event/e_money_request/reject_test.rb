require 'test_helper'
require 'sidekiq/testing'

class RejectTest < ActiveSupport::TestCase

  def setup
    Sidekiq.redis { |conn| conn.flushdb }

    @money_request = MoneyRequest.new
    @owner = User.last
    @manager = User.only_managers.first
    @second_manager = User.only_managers.second
    @finance_manager = User.only_finance_managers.first
    @money_request.stubs(:user).returns(@owner)
  end

  test 'successful reject from first approver who is a manager' do
    @money_request.stubs(:tracks => stub(:last => stub(:action_user => @manager)))
    @money_request.stubs(:rejected?).returns(true)
    @money_request.expects(:associated_users).with(@manager).twice.returns([@owner, @manager])
    @money_request.expects(:associated_users).with(@finance_manager, {:include_roles => true}).once.returns([@owner, @finance_manager, @second_manager, @manager])

    response = nil
    event = Event::EMoneyRequest::Reject.new(@manager, money_request: @money_request)
    # Ensure 2 mailers have been triggered
    assert_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size',2 do
      response = event.run
    end
    assert response.success?
    affected_users = event.affected_users
    assert affected_users.include?(@manager)
    assert affected_users.include?(@owner)
  end

  test 'successful reject from second approver who is a manager' do
    @money_request.stubs(:tracks => stub(:last => stub(:action_user => @manager)))
    @money_request.stubs(:rejected?).returns(true)
    @money_request.expects(:associated_users).with(@second_manager).twice.returns([@owner, @second_manager, @manager])
    @money_request.expects(:associated_users).with(@finance_manager, {:include_roles => true}).once.returns([@owner, @finance_manager, @second_manager, @manager])

    response = nil
    event = Event::EMoneyRequest::Reject.new(@second_manager, money_request: @money_request)
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

  test 'successful reject from finance manager' do
    @money_request.stubs(:tracks => stub(:last => stub(:action_user => @manager)))
    @money_request.stubs(:rejected?).returns(true)
    @money_request.expects(:associated_users).with(@finance_manager).twice.returns([@owner, @finance_manager, @second_manager, @manager])
    @money_request.expects(:associated_users).with(@finance_manager, {:include_roles => true}).once.returns([@owner, @finance_manager, @second_manager, @manager])

    response = nil
    event = Event::EMoneyRequest::Reject.new(@finance_manager, money_request: @money_request)
    # Ensure 3 mailers have been triggered
    assert_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size',4 do
      response = event.run
    end
    assert response.success?
    affected_users = event.affected_users
    assert affected_users.include?(@finance_manager)
    assert affected_users.include?(@second_manager)
    assert affected_users.include?(@manager)
    assert affected_users.include?(@owner)
  end

  test 'behavior when money_request is not passed' do
    response = nil
    event = Event::EMoneyRequest::Reject.new(@finance_manager, money_request: nil)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

  test 'behavior when current user is not passed' do
    response = nil
    event = Event::EMoneyRequest::Reject.new(nil, money_request: @money_request)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

  test 'behavior when current user is not passed and money_request is not passed ' do
    response = nil
    event = Event::EMoneyRequest::Reject.new(nil, money_request: nil)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

end
