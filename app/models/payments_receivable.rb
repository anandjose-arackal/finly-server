# == Schema Information
#
# Table name: payments_receivables
#
#  id                 :integer          not null, primary key
#  customer_id        :integer
#  amount_id          :integer
#  purpose            :text(65535)
#  expire_by          :date
#  company_id         :integer
#  initiating_user_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class PaymentsReceivable < ActiveRecord::Base
  belongs_to :customer
  belongs_to :amount
  belongs_to :company
  belongs_to :initiating_user, class_name: "User"

  accepts_nested_attributes_for :amount
end
