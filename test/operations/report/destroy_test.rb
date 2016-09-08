require 'test_helper'

class DestroyTest < ActiveSupport::TestCase

  def setup
    @user = User.first
    @report = @user.reports.first
    @other_report = User.second.reports.first
    @employee = User.find_by(email: 'user0@finlytest.io')
    @processing_report = @employee.reports.processing.first
  end

  test "Deletion of one's own reports" do
    assert_difference '@user.reports.count', -1 do
      @result = Report::Destroy.new(@user, {report_id: @report.id, role_id: 4}).run
      assert @result
    end
  end

  test "cannot delete another user's reports" do
    assert_no_difference '@user.reports.count' do
      begin
        @result = Report::Destroy.new(@user, {report_id: @other_report.id, role_id: 1}).run
      rescue NotAuthorizedException
        @result = nil
      end

      assert_not @result
      assert @report
    end
  end

  test "Report can only be destroyed in open or retracted state" do
    destroy_op = Report::Destroy.new(@employee, {report_id: @processing_report.id, role_id: 4})
    assert_no_difference '@employee.reports.count', 1 do
      @result = destroy_op.run
    end
    assert_not @result
    assert Report.exists?(@processing_report.id)
    assert_not destroy_op.errors.empty?
  end

end