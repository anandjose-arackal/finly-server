require 'test_helper'
require 'helpers/report_operation_test_helper'

class RejectReportTest < ActiveSupport::TestCase

  include ReportOperationTestHelper

  def setup
    @admin = User.first
    @employee = User.with_roles.only_employees.first

  end

  test "Report reject flow" do

  end
end