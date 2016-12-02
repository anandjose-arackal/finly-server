require 'test_helper'
require 'sidekiq/testing'

class CommentTest < ActiveSupport::TestCase

  def setup
    Sidekiq.redis { |conn| conn.flushdb }

    @report = Report.first
    @owner = users(:employee)
    @manager = users(:manager)
    @second_manager = users(:second_manager)
    @finance_manager = users(:finance_manager)
    @report.stubs(:user).returns(@owner)
  end

  test 'all associated users except current user will receive a message when a new comment is added to the report' do
    content = 'Test content'
    @report.stubs(:comments => stub(:last => ReportComment.new(user: @manager,
                                                               report_comment_action_id: ReportCommentAction.id_for(:report_comment), 
                                                               content: content)))
    @report.stubs(:associated_users).returns(User.with_id([@owner.id, @manager.id, @second_manager.id, @finance_manager.id]))

    response = nil
    event = Event::EReport::EComment::Create.new(@finance_manager, report: @report)
    # Ensure 3 mailers have been triggered
    assert_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size',3 do
      response = event.run
    end
    assert response.success?
    affected_users = event.affected_users
    assert affected_users.include?(@manager)
    assert affected_users.include?(@second_manager)
    assert affected_users.include?(@owner)
    assert_not affected_users.include?(@finance_manager)
  end

  test 'behavior when report is not passed for comment create' do
    response = nil
    event = Event::EReport::EComment::Create.new(@finance_manager, report: nil)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

  test 'behavior when current user is not passed for comment create' do
    response = nil
    event = Event::EReport::EComment::Create.new(nil, report: @report)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

  test 'behavior when current user is not passed and report is not passed for comment create' do
    response = nil
    event = Event::EReport::EComment::Create.new(nil, report: nil)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

end
