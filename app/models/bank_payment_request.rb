# == Schema Information
#
# Table name: bank_payment_requests
#
#  id                       :integer          not null, primary key
#  owner_id                 :integer
#  status_id                :integer
#  controlling_user_id      :integer
#  payment_order_id         :integer
#  name                     :string(255)
#  requested_amount_id      :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  submitted_at             :datetime
#  controlling_user_role_id :integer
#

class BankPaymentRequest < ActiveRecord::Base


  belongs_to :status, class_name: "BankPaymentRequestStatus"
  belongs_to :payment_order
  belongs_to :requested_amount, class_name: "Amount"

  has_many :bank_payment_request_comments
  has_many :bank_payment_request_trails

  accepts_nested_attributes_for :payment_order
  accepts_nested_attributes_for :requested_amount

  delegate :open?, :submitted?, :retracted?, :rejected?, :approved?, :credited?, to: :status
end
