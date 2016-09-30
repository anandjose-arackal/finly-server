# == Schema Information
#
# Table name: reports
#
#  id                      :integer          not null, primary key
#  name                    :string(255)      not null
#  user_id                 :integer          not null
#  report_status_id        :integer          not null
#  policy_id               :integer
#  submitted_at            :datetime
#  controlling_user_id     :integer
#  controlling_for_user_id :integer
#  memo                    :string(255)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  reimbursement_id        :integer
#  reimbursement_amount_id :integer
#  accounted               :boolean          default(FALSE), not null
#  archived                :boolean          default(FALSE), not null
#  is_deleted              :boolean          default(FALSE), not null
#

require 'test_helper'
require 'helpers/report_service_test_helper'

class ReportTest < ActiveSupport::TestCase
  include ReportServiceTestHelper
  # test "the truth" do
  #   assert true
  # end

  test 'an empty report cannot be submitted' do
    user = User.find_by(email: 'user0@finlytest.io')
    report = dummy_report_flow user, create: true
    assert report.valid?
    assert report.open?
    assert_not report.update(report_status_id: ReportStatus.processing_id)
    assert report.reload.open?

    report = dummy_report_flow user, create_and_add_expenses: true
    assert report.valid?
    assert report.open?
    assert report.update(report_status_id: ReportStatus.processing_id)
    assert report.reload.processing?
  end

end
