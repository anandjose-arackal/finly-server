require 'test_helper'
require 'sidekiq/testing'

class ApproveTest < ActiveSupport::TestCase

  def setup
    Sidekiq.redis { |conn| conn.flushdb }

    @money_request = MoneyRequest.new
    @owner = User.last
    @approving_manager = User.only_managers.first
    @finance_manager = User.only_finance_managers.first
    @money_request.stubs(:user).returns(@owner)
  end

  test 'successful approve when money_request is waiting for approval from another manager' do
    @money_request.stubs(:controlling_user).returns(@finance_manager)
    @money_request.stubs(:tracks => stub(:last => stub(:action_user => @approving_manager)))
    @money_request.stubs(:approved?).returns(false)

    response = nil
    event = Event::EMoneyRequest::Approve.new(@approving_manager, money_request: @money_request)
    # Ensure 2 mailers have been triggered
    assert_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size',2 do
      response = event.run
    end
    assert response.success?
    affected_users = event.affected_users
    # Check if mailer is passed to approving user
    assert affected_users.include?(@approving_manager)
    # Check if mailer is passed to new manager
    assert affected_users.include?(@finance_manager)
  end

  test 'successful approve when money_request is approved where final approver is manager' do
    @money_request.stubs(:approved?).returns(true)
    @money_request.stubs(:controlling_user).returns(nil)
    @money_request.stubs(:tracks => stub(:last => stub(:action_user => @approving_manager)))

    response = nil
    event = Event::EMoneyRequest::Approve.new(@approving_manager, money_request: @money_request)
    # Ensure 2 mailers have been triggered
    assert_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size',2 do
      response = event.run
    end
    assert response.success?
    affected_users = event.affected_users
    # Check if mailer is passed to approving user
    assert affected_users.include?(@approving_manager)
    # Check if mailer is passed to owner
    assert affected_users.include?(@owner)
  end

  test 'successful approve when money_request is approved where final approver is finance manager' do
    @money_request.stubs(:approved?).returns(true)
    @money_request.stubs(:controlling_user).returns(@finance_manager)
    @money_request.stubs(:tracks => stub(:last => stub(:action_user => @finance_manager)))

    response = nil
    event = Event::EMoneyRequest::Approve.new(@finance_manager, money_request: @money_request)
    # Ensure 2 mailers have been triggered
    assert_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size',2 do
      response = event.run
    end
    assert response.success?
    affected_users = event.affected_users
    # Check if mailer is passed to approving user
    assert affected_users.include?(@finance_manager)
    # Check if mailer is passed to owner
    assert affected_users.include?(@owner)
  end

  test 'successful auto-approve' do
    @money_request.stubs(:approved?).returns(true)
    @money_request.stubs(:controlling_user).returns(nil)
    @money_request.stubs(:tracks => stub(:last => stub(:action_user => nil)))

    response = nil
    event = Event::EMoneyRequest::Approve.new(nil, money_request: @money_request, auto_approve: true)
    # Ensure 1 mailers have been triggered
    assert_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size',1 do
      response = event.run
    end
    assert response.success?
    affected_users = event.affected_users
    # Check if mailer is passed to owner
    assert affected_users.include?(@owner)
    assert_equal affected_users.size, 1
  end

  test 'behavior when money_request is not passed' do
    response = nil
    event = Event::EMoneyRequest::Approve.new(@finance_manager, money_request: nil)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

  test 'behavior when current user is not passed' do
    response = nil
    event = Event::EMoneyRequest::Approve.new(nil, money_request: @money_request)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

  test 'behavior when current user is not passed and money_request is not passed ' do
    response = nil
    event = Event::EMoneyRequest::Approve.new(nil, money_request: nil)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

end
