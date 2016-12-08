require 'test_helper'
require 'sidekiq/testing'

class ApproveReportEventTest < ActiveSupport::TestCase

  def setup
    Sidekiq.redis { |conn| conn.flushdb }

    @report = Report.first
    @owner = User.last
    @approving_manager = User.only_managers.first
    @finance_manager = User.only_finance_managers.first
    @report.stubs(:user).returns(@owner)
  end

  test 'successful approve when report is waiting for approval from another manager' do
    @report.stubs(:controlling_user).returns(@finance_manager)
    @report.stubs(:tracks => stub(:last => stub(:action_user => @approving_manager)))
    @report.stubs(:approved?).returns(false)

    response = nil
    event = Event::EReport::Approve.new(@approving_manager, report: @report)
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

  test 'successful approve when report is approved where final approver is manager' do
    @report.stubs(:approved?).returns(true)
    @report.stubs(:controlling_user).returns(nil)
    @report.stubs(:tracks => stub(:last => stub(:action_user => @approving_manager)))

    response = nil
    event = Event::EReport::Approve.new(@approving_manager, report: @report)
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

  test 'successful approve when report is approved where final approver is finance manager' do
    @report.stubs(:approved?).returns(true)
    @report.stubs(:controlling_user).returns(@finance_manager)
    @report.stubs(:tracks => stub(:last => stub(:action_user => @finance_manager)))

    response = nil
    event = Event::EReport::Approve.new(@finance_manager, report: @report)
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

  test 'behavior when report is not passed for approve' do
    response = nil
    event = Event::EReport::Approve.new(@finance_manager, report: nil)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

  test 'behavior when current user is not passed for approve' do
    response = nil
    event = Event::EReport::Approve.new(nil, report: @report)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

  test 'behavior when current user is not passed and report is not passed for approve' do
    response = nil
    event = Event::EReport::Approve.new(nil, report: nil)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

end
