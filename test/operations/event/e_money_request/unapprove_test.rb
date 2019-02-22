require 'test_helper'
require 'sidekiq/testing'

class UnapproveTest < ActiveSupport::TestCase

  def setup
    Sidekiq.redis { |conn| conn.flushdb }

    @money_request = MoneyRequest.new
    @owner = User.last
    @manager = User.only_managers.first
    @finance_manager = User.only_finance_managers.first
    @money_request.stubs(:user).returns(@owner)
  end

  test 'unapproving money_request when money_request was in processing state' do
    @money_request.stubs(:processing?).returns(true)
    @money_request.stubs(:controlling_user).returns(@manager)
    @money_request.stubs(:tracks => stub(:last => stub(:modified_user => @finance_manager, modified_user_role_id: nil)))

    response = nil
    event = Event::EMoneyRequests::Unapprove.new(@manager, money_request: @money_request)
    # Ensure 2 mailers have been triggered
    assert_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size',2 do
      response = event.run
    end
    assert response.success?
    affected_users = event.affected_users
    # Check if mailer is passed to unapproving user
    assert affected_users.include?(@manager)
    # Check if mailer is passed to manager
    assert affected_users.include?(@finance_manager)
  end

  test 'unapproving money_request when money_request is in approved state' do
    @money_request.stubs(:approved?).returns(true)
    @money_request.stubs(:controlling_user).returns(@manager)
    @money_request.stubs(:tracks => stub(:last => stub(:modified_user => nil, modified_user_role_id: nil)))

    response = nil
    event = Event::EMoneyRequests::Unapprove.new(@manager, money_request: @money_request)
    # Ensure 1 mailers have been triggered
    assert_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size',1 do
      response = event.run
    end
    assert response.success?
    affected_users = event.affected_users
    # Check if mailer is passed to unapproving user
    assert affected_users.include?(@manager)
  end

  test 'behavior when money_request is not passed' do
    response = nil
    event = Event::EMoneyRequests::Approve.new(@finance_manager, money_request: nil)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

  test 'behavior when current user is not passed' do
    response = nil
    event = Event::EMoneyRequests::Approve.new(nil, money_request: @money_request)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

  test 'behavior when current user is not passed and money_request is not passed ' do
    response = nil
    event = Event::EMoneyRequests::Approve.new(nil, money_request: nil)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

end
