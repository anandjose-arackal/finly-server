require 'test_helper'
require 'sidekiq/testing'

class RetractTest < ActiveSupport::TestCase

  def setup
    Sidekiq.redis { |conn| conn.flushdb }

    @report = Report.first
    @owner = User.last
    @manager = User.only_managers.first
    @second_manager = User.only_managers.first
    @finance_manager = User.only_finance_managers.second
    @report.stubs(:user).returns(@owner)
  end

  test 'retract from first approver' do
    @report.stubs(:tracks => stub(:last => stub(:modified_user => @manager)))
    @report.stubs(:associated_users).returns([@manager, @owner])

    response = nil
    event = Event::EReport::Retract.new(@owner, report: @report)
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
    @report.stubs(:tracks => stub(:last => stub(:modified_user => @second_manager)))
    @report.stubs(:associated_users).returns([@second_manager, @manager, @owner])

    response = nil
    event = Event::EReport::Retract.new(@owner, report: @report)
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

  test 'behavior when report is not passed' do
    response = nil
    event = Event::EReport::Retract.new(@finance_manager, report: nil)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

  test 'behavior when current user is not passed' do
    response = nil
    event = Event::EReport::Retract.new(nil, report: @report)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

  test 'behavior when current user is not passed and report is not passed ' do
    response = nil
    event = Event::EReport::Retract.new(nil, report: nil)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

end
