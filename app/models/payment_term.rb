# == Schema Information
#
# Table name: payment_terms
#
#  id          :integer          not null, primary key
#  name        :text(65535)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  days_after  :integer
#  description :text(65535)
#  company_id  :integer
#  default     :boolean
#

class PaymentTerm < ActiveRecord::Base

  # have to seed this with common values from the internet
  def self.values
    []
  end
end
