require 'test_helper'
require 'sidekiq/testing'

class TakeControlTest < ActiveSupport::TestCase

  def setup
    Sidekiq.redis { |conn| conn.flushdb }

    @report = Report.first
    @owner = User.last
    @admin = User.only_admins.first
    @manager = User.only_managers.last
    @report.stubs(:user).returns(@owner)
  end

  test 'admin taking control of report from approver' do
    @report.stubs(:controlling_user).returns(@admin)
    @report.stubs(:controlling_for_user).returns(@manager)
    @report.stubs(:owner).returns(@owner)

    response = nil
    event = Event::EReport::TakeControl.new(@admin, report: @report)
    # Ensure 2 mailers have been triggered
    assert_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size',2 do
      response = event.run
    end
    assert response.success?
    affected_users = event.affected_users
    assert affected_users.include?(@admin)
    assert affected_users.include?(@manager)
    assert_not affected_users.include?(@owner)
    assert_equal affected_users.size, 2
  end

  test 'behavior when report is not passed' do
    response = nil
    event = Event::EReport::TakeControl.new(@admin, report: nil)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

  test 'behavior when current user is not passed' do
    response = nil
    event = Event::EReport::TakeControl.new(nil, report: @report)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

  test 'behavior when current user is not passed and report is not passed ' do
    response = nil
    event = Event::EReport::TakeControl.new(nil, report: nil)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

end
