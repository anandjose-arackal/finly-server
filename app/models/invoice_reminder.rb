# == Schema Information
#
# Table name: invoice_reminders
#
#  id                  :integer          not null, primary key
#  days                :integer
#  reference_date_type :integer
#  timeframe_type      :string(255)
#  company_id          :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class InvoiceReminder < ActiveRecord::Base

  belongs_to :company
  
  REFERENCE_DATE_TYPES = ["date", "due_date"]
  TIMEFRAME_TYPES = ["before", "after"]

  validates :reference_date_type, inclusion: REFERENCE_DATE_TYPES
  validates :timeframe_type, inclusdion: TIMEFRAME_TYPES
end
