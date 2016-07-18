# == Schema Information
#
# Table name: payment_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PaymentType < ActiveRecord::Base
  has_many :payments

  def self.advance_id
    1
  end

  def self.debt_clearance_id
    2
  end

  def self.reimbursement_id
    3
  end
end
