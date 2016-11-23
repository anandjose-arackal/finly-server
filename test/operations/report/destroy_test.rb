require 'test_helper'

class DestroyTest < ActiveSupport::TestCase

  def setup
    @user = User.first
    @report = @user.reports.first
    @employee = User.find_by(email: 'user0@finlytest.io')
  end

  test "successful deletion of one's own reports that's in open state" do
    # ensuring the report is in open state
    Report.any_instance.stubs(:open?).returns(true)

    assert_difference '@user.reports.exclude_deleted.count', -1 do
      @result = Report::Destroy.new(@user, {report_id: @report.id, role_id: 4}).run
    end
    assert @result.success?
  end

  test "successful deletion of one's own report in retracted state" do
    # stubbing the report state to be in retracted state
    Report.any_instance.stubs(:retracted?).returns(true)

    assert_difference '@user.reports.exclude_deleted.count', -1 do
      @result = Report::Destroy.new(@user, {report_id: @report.id, role_id: 4}).run
    end
    assert @result.success?
  end

  test "cannot delete a report that's not in open/retracted/rejected state" do
    # stubbing the state of the report
    Report.any_instance.stubs(:open?).returns(false)
    Report.any_instance.stubs(:rejected?).returns(false)
    Report.any_instance.stubs(:retracted?).returns(false)

    assert_no_difference '@user.reports.exclude_deleted.count' do
      @result = Report::Destroy.new(@user, {report_id: @report.id, role_id: 4}).run
    end
    assert_not @result.success?
    assert_not @report.is_deleted
  end

  test "cannot delete another user's reports" do
    # stubbing report owner
    Report.any_instance.stubs(:user_id).returns(User.second.id)

    assert_no_difference '@user.reports.exclude_deleted.count' do
      begin
        @result = Report::Destroy.new(@user, {report_id: @report.id, role_id: 1}).run
      rescue NotAuthorizedException
        @rescued = true
      end
      assert @rescued

    end
  end

  test ""

end