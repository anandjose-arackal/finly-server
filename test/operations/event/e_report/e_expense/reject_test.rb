require 'test_helper'
require 'sidekiq/testing'

class RejectTest < ActiveSupport::TestCase

  def setup
    Sidekiq.redis { |conn| conn.flushdb }

    @report = Report.first
    @owner = User.last
    @rejected_expense = Expense.first
    @first_approver = User.only_managers.first
    @second_approver = User.only_finance_managers.first
    @report.stubs(:user).returns(@owner)
  end

  test 'successful reject from first approver' do
    @report.expects(:associated_users).with(@first_approver).twice.returns([@owner, @first_approver])

    response = nil
    event = Event::EReport::EExpense::Reject.new(@first_approver, report: @report, rejected_expense: @rejected_expense)
    # Ensure 2 mailers have been triggered
    assert_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size',2 do
      response = event.run
    end
    assert response.success?
    affected_users = event.affected_users
    assert affected_users.include?(@first_approver)
    assert affected_users.include?(@owner)
  end

  test 'successful reject from second approver' do
    @report.expects(:associated_users).with(@second_approver).twice.returns([@owner, @first_approver, @second_approver])

    response = nil
    event = Event::EReport::EExpense::Reject.new(@second_approver, report: @report, rejected_expense: @rejected_expense)
    # Ensure 3 mailers have been triggered
    assert_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size',3 do
      response = event.run
    end
    assert response.success?
    affected_users = event.affected_users
    assert affected_users.include?(@second_approver)
    assert affected_users.include?(@first_approver)
    assert affected_users.include?(@owner)
  end

  test 'behavior when report is not passed' do
    response = nil
    event = Event::EReport::EExpense::Reject.new(@first_approver, report: nil, rejected_expense: @rejected_expense)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

  test 'behavior when current user is not passed' do
    response = nil
    event = Event::EReport::EExpense::Reject.new(nil, report: @report, rejected_expense: @rejected_expense)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

    test 'behavior when rejected expense is not passed' do
    response = nil
    event = Event::EReport::EExpense::Reject.new(@first_approver, report: @report, rejected_expense: nil)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end

  test 'behavior when current user,report and rejected expense is not passed ' do
    response = nil
    event = Event::EReport::EExpense::Reject.new(nil, report: nil, rejected_expense: nil)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      response = event.run
    end
    assert response.failure?
  end


end
