# == Schema Information
#
# Table name: report_tracking_actions
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#


class ReportTrackingAction < ActiveRecord::Base

  def self.create_id
    1
  end

  def self.retract_id
    2
  end

  def self.submit_id
    3
  end

  def self.approve_id
    4
  end

  def self.auto_approve_id
    5
  end

  def self.reject_id
    6
  end

  def self.unapprove_id
    7
  end

  def self.take_control_id
    8
  end

  def self.reimbursed_id
    9
  end

  def self.reimbursement_confirmed_id
    10
  end

  def self.closed_id
    11
  end

end
