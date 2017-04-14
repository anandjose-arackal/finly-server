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
  scope :with_name, -> (name) { find_by(name: name)}

  STATES = {open: 1, processing: 2, retracted: 3, retracted: 4, approved: 5, settled: 6, settlement_confirmed: 7, closed: 8}

  def self.personal_sort_order
    [ReportStatus.id_for(:open), ReportStatus.id_for(:retracted), ReportStatus.id_for(:processing), ReportStatus.id_for(:rejected),
     ReportStatus.id_for(:approved), ReportStatus.id_for(:settled), ReportStatus.id_for(:settlement_confirmed), ReportStatus.id_for(:closed)]
  end

  def self.id_for(status)
    STATES[status]
  end

  def status_name
    self.name
  end

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

  def settled?
    self.id == ReportStatus.settled_id
  end

  def settlement_confirmed?
    self.id == ReportStatus.settlement_confirmed_id
  end

  def closed?
    self.id == ReportStatus.closed_id
  end

  def self.open_id
    1
  end

  def self.processing_id
    2
  end

  def self.retracted_id
    3
  end

  def self.rejected_id
    4
  end

  def self.approved_id
    5
  end

  def self.settled_id
    6
  end

  def self.settlement_confirmed_id
    7
  end

  def self.closed_id
    8
  end

end
