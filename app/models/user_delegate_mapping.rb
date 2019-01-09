# == Schema Information
#
# Table name: user_delegate_mappings
#
#  id                     :integer          not null, primary key
#  user_id                :integer
#  delegate_for_user_id   :integer
#  expense_create         :boolean
#  expense_update         :boolean
#  receipt_create         :boolean
#  receipt_add_to_expense :boolean
#  receipt_update         :boolean
#  report_create          :boolean
#  report_submit          :boolean
#  report_retract         :boolean
#  report_update          :boolean
#  money_request_create   :boolean
#  money_request_update   :boolean
#  money_request_submit   :boolean
#  money_request_retract  :boolean
#  trip_create            :boolean
#  trip_update            :boolean
#  trip_submit            :boolean
#  trip_retract           :boolean
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class UserDelegateMapping < ActiveRecord::Base

  belongs_to :user
  belongs_to :delegate_for_user, class_name: "User"

end