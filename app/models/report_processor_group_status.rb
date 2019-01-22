# == Schema Information
#
# Table name: report_processor_group_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ReportProcessorGroupStatus < ApplicationRecord
  include Seedable

  def self.values
    [:pending, :scheduled, :processing, :partially_completed, :completed, :failed, :cancelled]
  end

  def pending?
    self.id == ReportProcessorGroupStatus.id_for(:pending)
  end

  def scheduled?
    self.id == ReportProcessorGroupStatus.id_for(:scheduled)
  end

  def processing?
    self.id == ReportProcessorGroupStatus.id_for(:processing)
  end

  def partially_completed?
    self.id == ReportProcessorGroupStatus.id_for(:partially_completed)
  end

  def completed?
    self.id == ReportProcessorGroupStatus.id_for(:completed)
  end

  def failed?
    self.id == ReportProcessorGroupStatus.id_for(:failed)
  end

  def cancelled?
    self.id == ReportProcessorGroupStatus.id_for(:cancelled)
  end

  def as_json(options={})
    {
        id: id,
        name: name&.humanize
    }
  end

end
