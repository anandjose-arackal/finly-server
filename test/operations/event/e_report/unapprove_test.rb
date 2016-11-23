require 'test_helper'
require 'sidekiq/testing'

class UnapproveTest < ActiveSupport::TestCase

  def setup
    Sidekiq.redis { |conn| conn.flushdb }

    @report = Report.first
    @owner = User.last
    @manager = User.only_managers.first
    @finance_manager = User.only_finance_managers.first
    @report.stubs(:user).returns(@owner)
  end

  test 'unapproving report when report was in processing state' do
    @report.stubs(:processing?).returns(true)
    @report.stubs(:controlling_user).returns(@manager)
    @report.stubs(:tracks => stub(:last => stub(:modified_user => @finance_manager)))

    response = nil
    event = Event::EReport::Unapprove.new(@manager, report: @report)
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

  test 'unapproving report when report is in approved state' do
    @report.stubs(:approved?).returns(true)
    @report.stubs(:controlling_user).returns(@manager)
    @report.stubs(:tracks => stub(:last => stub(:modified_user => nil)))

    response = nil
    event = Event::EReport::Unapprove.new(@manager, report: @report)
    # Ensure 1 mailers have been triggered
    assert_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size',1 do
      response = event.run
    end
    assert response.success?
    affected_users = event.affected_users
    # Check if mailer is passed to unapproving user
    assert affected_users.include?(@manager)
  end

  test 'behavior when report is not passed' do
    response = nil
    event = Event::EReport::Approve.new(@finance_manager, report: nil)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

  test 'behavior when current user is not passed' do
    response = nil
    event = Event::EReport::Approve.new(nil, report: @report)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

  test 'behavior when current user is not passed and report is not passed ' do
    response = nil
    event = Event::EReport::Approve.new(nil, report: nil)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

end
