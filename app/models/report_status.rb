# == Schema Information
#
# Table name: report_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  order      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ReportStatus < ActiveRecord::Base

  scope :open, -> { find_by(id: ReportStatus.open_id) }
  scope :retracted, -> { find_by(id: ReportStatus.retracted_id) }
  scope :rejected, -> { find_by(id: ReportStatus.rejected_id) }
  scope :processing, -> { find_by(id: ReportStatus.processing_id) }
  scope :approved, -> { find_by(id: ReportStatus.approved_id) }
  scope :reimbursed, -> { find_by(id: ReportStatus.reimbursed_id) }
  scope :reimbursement_received, -> { find_by(id: ReportStatus.reimbursement_received_id) }
  scope :archived, -> { find_by(id: ReportStatus.archived_id) }

  def open?
    self.id == ReportStatus.open_id
  end

  def retracted?
    self.id == ReportStatus.retracted_id
  end

  def rejected?
    self.id == ReportStatus.rejected_id
  end

  def processing?
    self.id == ReportStatus.processing_id
  end

  def approved?
    self.id == ReportStatus.approved_id
  end

  def reimbursed?
    self.id == ReportStatus.reimbursed_id
  end

  def reimbursement_received?
    self.id == ReportStatus.reimbursement_received_id
  end

  def archived?
    self.id == ReportStatus.archived_id
  end

  def self.open_id
    1
  end

  def self.retracted_id
    2
  end

  def self.rejected_id
    3
  end

  def self.processing_id
    4
  end

  def self.approved_id
    5
  end

  def self.reimbursed_id
    6
  end

  def self.reimbursement_received_id
    7
  end

  def self.archived_id
    8
  end

end
