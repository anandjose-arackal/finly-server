require 'test_helper'
require 'sidekiq/testing'

class EventApproveReportTest < ActiveSupport::TestCase

  def setup
    @report = Report.first
    @owner = User.first
    @old_manager = User.second
    @finance_manager = User.third
    @report.stubs(:user).returns(@owner)
    @report.controlling_user(:user).returns(@finance_manager)
  end

  test 'Successful Approve Test' do
    
  end

end
