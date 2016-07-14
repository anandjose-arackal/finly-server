require 'test_helper'

class ViolationServiceTest < ActiveSupport::TestCase

  def setup
    # setting up the rules and reports for the violation handler

    @user = User.first
    # report service to create and perform operations on report
    @report_service = ReportService.new @user
    @expenses = @user.expenses.limit(5)

  end

  test 'should return violations in the report' do

  end

  test 'report without policy should not return any violations' do

  end

  test 'adding a new expense that hence violates budget is accurately detected' do

  end

  test 'removing a violating expense removes the warning messages' do

  end

  test 'editing an expense to correct the violation hence removes the particular violation' do

  end

  test 'deleting a rule removes all associated violations because of it' do

  end

end