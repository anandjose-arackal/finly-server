class ReportProcessorGroupMapping < ActiveRecord::Base
  belongs_to :user
  belongs_to :amount
end
