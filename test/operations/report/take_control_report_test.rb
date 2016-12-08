require 'test_helper'
require 'helpers/report_operation_test_helper'


class TakeControlReportTest < ActiveSupport::TestCase

  def setup
    @admin = users(:admin)
    @employee = users(:employee)
    @manager = users(:manager)
    # @second_manager = User.find_by(email: 'manager1@finlytest.io')
    # @third_manager = User.find_by(email: 'manager2@finlytest.io')
    @finance_manager = users(:finance_manager)
    # @second_finance_manager = User.find_by(email: 'finance1@finlytest.io')
    @report = @employee.reports.first
  end

  test "company admins can take control of the report" do
    # stubbing the face that the report can be taken control of at the moment
    Report.any_instance.stubs(:can_take_control?).returns(true)

    # stubbing the report returned by Report::Index
    reports_presenter = Report::Index::Presenter.new(@admin, {reports: Report.where(id: @report.id)}, nil)
    Report::Index.stubs(:call).returns(reports_presenter)
    take_control_op = Report::TakeControl.new(@admin, {report_id: @report.id, view: 'admin'})
    original_status_id = @report.status_id

    assert_difference 'ReportTrack.count', 1 do
      assert_difference 'ReportComment.count', 1 do
        @result = take_control_op.run
      end
    end

    assert_equal original_status_id, @report.status_id
    assert @result.success?
    assert_equal @result.report.controlling_user_id, @admin.id
    assert_equal @result.report.controlling_user_role_id, UserRole.admin_id

  end

  test "policy admins can take control of a report belonging to that policy" do
    # mocking the policy admin role of the user
    @employee.stubs(:policy_admin?).returns(true)
    # mocking the fact that the report has a policy
    Report.any_instance.stubs(:policy).returns(true)
    # stubbing the face that the report can be taken control of at the moment
    Report.any_instance.stubs(:can_take_control?).returns(true)
    # stubbing the Report::Violation method to return junk
    Report::Violation.stubs(:call).returns({})

    # stubbing the report returned by Report::Index
    reports_presenter = Report::Index::Presenter.new(@employee, {reports: Report.where(id: @report.id)}, nil)
    Report::Index.stubs(:call).returns(reports_presenter)
    take_control_op = Report::TakeControl.new(@employee, {report_id: @report.id, view: 'admin'})
    original_status_id = @report.status_id

    assert_difference 'ReportTrack.count', 1 do
      assert_difference 'ReportComment.count', 1 do
        @result = take_control_op.run
      end
    end

    assert @result.success?
    assert_equal @result.report.controlling_user_id, @employee.id
    assert_equal @result.report.controlling_user_role_id, UserRole.admin_id
    assert_equal original_status_id, @report.status_id
  end

  test "Report that is not in a submitted state cannot be taken control of" do
    # stubbing the face that the report can be taken control of at the moment
    Report.any_instance.stubs(:can_take_control?).returns(false)

    # stubbing the report returned by Report::Index
    reports_presenter = Report::Index::Presenter.new(@admin, {reports: Report.where(id: @report.id)}, nil)
    Report::Index.stubs(:call).returns(reports_presenter)
    take_control_op = Report::TakeControl.new(@admin, {report_id: @report.id, view: 'admin'})

    assert_no_difference 'ReportTrack.count' do
      assert_no_difference '@report.controlling_user_id' do
        @result = take_control_op.run
      end
    end

    assert_not @result.success?
    assert_not @result.messages[:error].empty?
  end

  test "non-company-admin or non-poliycy-admin cannot take control of a report" do
    # mocking the policy admin  and company admin role of the user
    @employee.stubs(:policy_admin?).returns(false)
    @employee.stubs(:company_admin?).returns(false)

    # storing the original status_id
    original_status_id = @report.status_id
    take_control_op = Report::TakeControl.new(@admin, {report_id: @report.id, view: 'admin'})

    assert_no_difference 'ReportTrack.count' do
      assert_no_difference '@report.controlling_user_id' do
        begin
          @result = take_control_op.run
        rescue NotAuthorizedException
          @rescued = true
        end
      end
    end

    assert @rescued
    # the report status doesn't change
    assert original_status_id, @report.status_id
  end

  test "" do

  end


  # test "only admins can take control of a report" do
  #   # first employee submits the report
  #   assert_difference '@user.reports.count', 1 do
  #     @report = create_report(@user)
  #   end
  #   assert @report
  #   assert_equal 5, @report.expenses.count
  #   assert_equal ReportStatus.open_id, @report.status_id
  #   submit_op = Report::Submit.new(@user, report_id: @report.id)
  #   assert_difference '@user.reports.processing.count', 1 do
  #     @report = submit_op.run
  #     assert @report
  #     assert_equal ReportStatus.processing_id, @report.status_id
  #     assert @report.tracks.present?
  #   end
  #
  #   # now admin tries to take control of the report.
  #   take_control_op = Report::TakeControl.new(@admin, {report_id: @report.id, role_id: UserRole.admin_id})
  #   assert_difference 'ReportTrack.count', 1 do
  #     @report = take_control_op.run
  #   end
  #   assert @report
  #   assert_equal @admin.id, @report.controlling_user_id
  #   assert_equal ReportStatus.processing_id, @report.status_id
  # end

  # test "non admins cannot take control of a report" do
  #   # first employee submits the report
  #   assert_difference '@user.reports.count', 1 do
  #     @report = create_report(@user)
  #   end
  #   assert @report
  #   assert_equal 5, @report.expenses.count
  #   assert_equal ReportStatus.open_id, @report.status_id
  #   submit_op = Report::Submit.new(@user, report_id: @report.id)
  #   assert_difference '@user.reports.processing.count', 1 do
  #     @report = submit_op.run
  #     assert @report
  #     assert_equal ReportStatus.processing_id, @report.status_id
  #     assert @report.tracks.present?
  #   end
  #
  #   # manager and finance manager try to take control of the report in vain
  #   take_control_op = Report::TakeControl.new(@manager, {report_id: @report.id, role_id: UserRole.admin_id})
  #   assert_no_difference 'ReportTrack.count' do
  #     begin
  #       @report = take_control_op.run
  #     rescue
  #       @rescued = true
  #     end
  #   end
  #   assert @rescued
  #   assert_equal @manager.id, @report.controlling_user_id
  #   assert_equal ReportStatus.processing_id, @report.status_id
  #
  #   # finance manager
  #   take_control_op = Report::TakeControl.new(@finance_manager, {report_id: @report.id, role_id: UserRole.admin_id})
  #   assert_no_difference 'ReportTrack.count' do
  #     begin
  #       @report = take_control_op.run
  #     rescue
  #       @rescued = true
  #     end
  #   end
  #   assert @rescued
  #   assert_equal @manager.id, @report.controlling_user_id
  #   assert_equal ReportStatus.processing_id, @report.status_id
  # end
end