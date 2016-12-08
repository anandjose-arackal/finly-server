require 'test_helper'
require 'sidekiq/testing'

class SubmitTest < ActiveSupport::TestCase

  def setup
    @money_request = MoneyRequest.new
    @owner = User.last
    @manager = User.only_managers.first
    @money_request.stubs(:user).returns(@owner)
  end

  test 'successful mailer sent with controlling user' do
    # Returns manager as controlling user
    @money_request.stubs(:controlling_user).returns(@manager)

    response = nil
    event = Event::EMoneyRequest::Submit.new(@owner, money_request: @money_request)
    # Ensure 2 mailers have been triggered
    assert_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size',2 do
      response = event.run
    end
    assert response.success?
    affected_users = event.affected_users
    # Check if mailer is sent to owner
    assert affected_users.include?(@owner)
    # Check if mailer is sent to manager
    assert affected_users.include?(@manager)
  end

  test 'successful mailer sent without controlling user' do
    @money_request.stubs(:controlling_user).returns(nil)

    response = nil
    event = Event::EMoneyRequest::Submit.new(@owner, money_request: @money_request)
    # Ensure 1 mailer have been triggered
    assert_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size',1 do
      response = event.run
    end
    assert response.success?
    affected_users = event.affected_users
    # Check if mailer is sent to owner
    assert affected_users.include?(@owner)
    # Check if mailer is sent to manager
    assert_not affected_users.include?(@manager)
  end

  test 'behavior when money_request is not sent' do
    response = nil
    event = Event::EMoneyRequest::Submit.new(@owner)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

  test 'behavior when current user is not sent' do
    response = nil
    event = Event::EMoneyRequest::Submit.new(nil, money_request: @money_request)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

  test 'behavior when current user is not sent and money_request is not sent ' do
    response = nil
    event = Event::EMoneyRequest::Submit.new(nil, money_request: nil)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

end
