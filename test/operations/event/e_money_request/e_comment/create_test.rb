require 'test_helper'
require 'sidekiq/testing'

class CommentTest < ActiveSupport::TestCase

  def setup
    Sidekiq.redis { |conn| conn.flushdb }

    @money_request = MoneyRequest.new
    @owner = User.last
    @manager = User.only_managers.first
    @second_manager = User.only_managers.second
    @finance_manager = User.only_finance_managers.last
    @money_request.stubs(:user).returns(@owner)
  end

  test 'all associated users except current user will receive a message when a new comment is added to the money_request' do
    content = 'Test content'
    @money_request.stubs(:comments => stub(:last => MoneyRequestComment.new(user: @manager,
                                                               comment_action_id: MoneyRequestCommentAction.id_for(:comment), 
                                                               content: content)))
    @money_request.stubs(:associated_users).returns(User.with_id([@owner.id, @manager.id, @second_manager.id, @finance_manager.id]))

    response = nil
    event = Event::EMoneyRequest::EComment::Create.new(@finance_manager, money_request: @money_request)
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

  test 'behavior when money_request is not passed' do
    response = nil
    event = Event::EMoneyRequest::EComment::Create.new(@finance_manager, money_request: nil)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

  test 'behavior when current user is not passed' do
    response = nil
    event = Event::EMoneyRequest::EComment::Create.new(nil, money_request: @money_request)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

  test 'behavior when current user is not passed and money_request is not passed ' do
    response = nil
    event = Event::EMoneyRequest::EComment::Create.new(nil, money_request: nil)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

end
