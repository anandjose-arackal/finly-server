# == Schema Information
#
# Table name: invoice_reminders
#
#  id                  :integer          not null, primary key
#  days                :integer
#  reference_date_type :string(255)
#  timeframe_type      :string(255)
#  company_id          :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  name                :string(255)
#

class InvoiceReminder < ApplicationRecord

  belongs_to :company, optional: true

  REFERENCE_DATE_TYPES = ["date", "due_date", nil]
  TIMEFRAME_TYPES = ["before", "after", nil]

  validates :reference_date_type, inclusion: { in: REFERENCE_DATE_TYPES }
  validates :timeframe_type, inclusion: { in: TIMEFRAME_TYPES }

  scope :with_id, -> (id) { where id: id }
end
