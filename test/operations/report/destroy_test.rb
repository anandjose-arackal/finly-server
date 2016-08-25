require 'test_helper'

class DestroyTest < ActiveSupport::TestCase

  def setup
    @user = User.first
    @report = @user.reports.first
    @other_report = User.second.reports.first
  end

  test "Deletion of one's own reports" do
    assert_difference '@user.reports.count', -1 do
      @result = Report::Destroy.new(@user, report_id: @report.id).run
      assert @result
    end
  end

  test "cannot delete another user's reports" do
    assert_no_difference '@user.reports.count' do
      begin
        @result = Report::Destroy.new(@user, report_id: @other_report.id).run
      rescue NotAuthorizedException
        @result = nil
      end

      assert_not @result
      assert @report
    end
  end

end