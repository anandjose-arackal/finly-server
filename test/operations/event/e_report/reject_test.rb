require 'test_helper'
require 'sidekiq/testing'

class RejectTest < ActiveSupport::TestCase

  def setup
    Sidekiq.redis { |conn| conn.flushdb }

    @report = Report.first
    @owner = User.first
    @manager = User.only_managers.first
    @second_manager = User.only_managers.second
    @finance_manager = User.only_finance_managers.first
    @report.stubs(:user).returns(@owner)
  end

  test 'successful reject from first approver who is a manager' do
    @report.stubs(:tracks => stub(:last => stub(:action_user => @manager)))
    @report.stubs(:rejected?).returns(true)
    @report.expects(:associated_users).with(@manager).twice.returns([@owner, @manager])

    response = nil
    event = Event::EReport::Reject.new(@manager, report: @report)
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
    @report.stubs(:tracks => stub(:last => stub(:action_user => @manager)))
    @report.stubs(:rejected?).returns(true)
    @report.expects(:associated_users).with(@second_manager).twice.returns([@owner, @second_manager, @manager])

    response = nil
    event = Event::EReport::Reject.new(@second_manager, report: @report)
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
    @report.stubs(:tracks => stub(:last => stub(:action_user => @manager)))
    @report.stubs(:rejected?).returns(true)
    @report.expects(:associated_users).with(@finance_manager).twice.returns([@owner, @finance_manager, @second_manager, @manager])

    response = nil
    event = Event::EReport::Reject.new(@finance_manager, report: @report)
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

  test 'behavior when report is not passed' do
    response = nil
    event = Event::EReport::Reject.new(@finance_manager, report: nil)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

  test 'behavior when current user is not passed' do
    response = nil
    event = Event::EReport::Reject.new(nil, report: @report)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

  test 'behavior when current user is not passed and report is not passed ' do
    response = nil
    event = Event::EReport::Reject.new(nil, report: nil)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

end
