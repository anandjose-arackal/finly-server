class ReportProcessorGroupStatus < ActiveRecord::Base
  include Seedable

  def self.values
    [:processing, :partially_completed, :completed, :failed, :cancelled]
  end

end
