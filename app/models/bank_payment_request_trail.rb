# == Schema Information
#
# Table name: bank_payment_request_trails
#
#  id                      :integer          not null, primary key
#  bank_payment_request_id :integer
#  request_status_id       :integer
#  action_user_id          :integer
#  action_user_role_id     :integer
#  modified_user_id        :integer
#  modified_user_role_id   :integer
#  action_id               :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

class BankPaymentRequestTrail < ActiveRecord::Base
  belongs_to :bank_payment_request
  belongs_to :action_user, class_name: "User"
  belongs_to :modified_user, class_name: "User"
  belongs_to :action_user_role, class_name: "UserRole"
  belongs_to :modified_user_role, class_name: "UserRole"
  belongs_to :action, class_name: "BankPaymentRequestTrailAction"

end
