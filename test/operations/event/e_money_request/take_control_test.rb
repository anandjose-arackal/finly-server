require 'test_helper'
require 'sidekiq/testing'

class TakeControlTest < ActiveSupport::TestCase

  def setup
    Sidekiq.redis { |conn| conn.flushdb }

    @money_request = MoneyRequest.new
    @owner = User.last
    @admin = User.only_admins.first
    @manager = User.only_managers.where.not(id: [@owner.id, @admin.id]).last
    @money_request.stubs(:user).returns(@owner)
  end

  test 'admin taking control of money_request from approver' do
    @money_request.stubs(:controlling_user).returns(@admin)
    @money_request.stubs(:controlling_for_user).returns(@manager)
    @money_request.stubs(:owner).returns(@owner)

    response = nil
    event = Event::EMoneyRequests::TakeControl.new(@admin, money_request: @money_request)
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

  test 'behavior when money_request is not passed' do
    response = nil
    event = Event::EMoneyRequests::TakeControl.new(@admin, money_request: nil)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

  test 'behavior when current user is not passed' do
    response = nil
    event = Event::EMoneyRequests::TakeControl.new(nil, money_request: @money_request)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

  test 'behavior when current user is not passed and money_request is not passed ' do
    response = nil
    event = Event::EMoneyRequests::TakeControl.new(nil, money_request: nil)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

end
