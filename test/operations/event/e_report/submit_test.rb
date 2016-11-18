require 'test_helper'
require 'sidekiq/testing'

class EventSubmitReportTest < ActiveSupport::TestCase

  def setup
    @report = Report.first
    @owner = User.first
    @manager = User.second
    @report.stubs(:user).returns(@owner)
  end

  test 'successfull mailer sent with controlling user' do
    # Returns manager as controlling user
    @report.stubs(:controlling_user).returns(@manager)

    response = nil
    event = Event::EReport::Submit.new(@owner, report: @report)
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

  test 'successfull mailer sent without controlling user' do
    @report.stubs(:controlling_user).returns(nil)

    response = nil
    event = Event::EReport::Submit.new(@owner, report: @report)
    # Ensure 2 mailers have been triggered
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

  test 'behavior when report is not sent' do
    response = nil
    event = Event::EReport::Submit.new(@owner)
    # Ensure 2 mailers have been triggered
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

  test 'behavior when current user is not sent' do
    response = nil
    event = Event::EReport::Submit.new(nil, report: @report)
    # Ensure 2 mailers have been triggered
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

    test 'behavior when current user is not sent and report is not sent	' do
    response = nil
    event = Event::EReport::Submit.new(nil, report: nil)
    # Ensure 2 mailers have been triggered
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

end
