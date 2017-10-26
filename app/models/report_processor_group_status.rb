class ReportProcessorGroupStatus < ActiveRecord::Base
  include Seedable

  def self.values
    [:processing, :partially_completed, :completed, :marked_as_paid, :failed, :cancelled]
  end

end
