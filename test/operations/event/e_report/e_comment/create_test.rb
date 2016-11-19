require 'test_helper'
require 'sidekiq/testing'

class CommentTest < ActiveSupport::TestCase

  def setup
    Sidekiq.redis { |conn| conn.flushdb }

    @report = Report.first
    @owner = User.first
    @manager = User.only_managers.first
    @second_manager = User.only_managers.second
    @finance_manager = User.only_finance_managers.first
    @report.stubs(:user).returns(@owner)
  end

  test 'All associated users will receiving a message when a new comment is added to the report' do

  end

  # test 'behavior when report is not passed' do
  #   response = nil
  #   event = Event::EReport::Approve.new(@finance_manager, report: nil)
  #   assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
  #     response = event.run
  #   end
  #   assert response.failure?
  # end

  # test 'behavior when current user is not passed' do
  #   response = nil
  #   event = Event::EReport::Approve.new(nil, report: @report)
  #   assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
  #     response = event.run
  #   end
  #   assert response.failure?
  # end

  # test 'behavior when current user is not passed and report is not passed ' do
  #   response = nil
  #   event = Event::EReport::Approve.new(nil, report: nil)
  #   assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
  #     response = event.run
  #   end
  #   assert response.failure?
  # end

end
