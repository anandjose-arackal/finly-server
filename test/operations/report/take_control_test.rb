require 'test_helper'
require 'helpers/report_operation_test_helper'


class TakeControlTest < ActiveSupport::TestCase

  def setup
    @admin = User.first
    @employee = User.find_by(email: 'user0@finlytest.io')
    @manager = User.find_by(email: 'manager0@finlytest.io')
    @second_manager = User.find_by(email: 'manager1@finlytest.io')
    @third_manager = User.find_by(email: 'manager2@finlytest.io')
    @finance_manager = User.find_by(email: 'finance0@finlytest.io')
    @second_finance_manager = User.find_by(email: 'finance1@finlytest.io')
    @report = @employee.reports.first
  end

  test "company admins can take control of the report" do
    # stubbing the face that the report can be taken control of at the moment
    Report.any_instance.stubs(:can_take_control?).returns(true)

    # stubbing the report returned by Report::Index
    reports_presenter = Report::Index::Presenter.new(@admin, {reports: Report.where(id: @report.id)}, nil)
    Report::Index.stubs(:call).returns(reports_presenter)
    take_control_op = Report::TakeControl.new(@admin, {report_id: @report.id, view: 'admin'})

    assert_difference 'ReportTrack.count', 1 do
      assert_no_difference '@report.status_id' do
        @result = take_control_op.run
      end
    end

    assert @result.success?
    assert_equal @result.report.controlling_user_id, @admin.id

  end

  test "policy admins can take control of a report belonging to that policy" do
    @employee.stubs(:policy_admin?).returns(true)

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