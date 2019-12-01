# == Schema Information
#
# Table name: bbps_biller_subscriptions
#
#  id                       :bigint           not null, primary key
#  bbps_biller_id           :bigint           not null
#  name                     :string(255)      not null
#  department_id            :integer
#  cost_center_id           :integer
#  location_id              :integer
#  policy_id                :integer
#  note                     :text(65535)
#  active                   :boolean          default(TRUE)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  status_id                :integer          not null
#  deleted_at               :datetime
#  subscription_id          :string(255)
#  require_poc_verification :boolean          default(TRUE)
#  user_id                  :integer
#  agreement_id             :integer
#  expected_bill_day        :string(255)
#  controlling_level_id     :integer
#  reminder_before_days     :string(255)
#  biller_category_name     :string(255)
#  submitted_at             :datetime
#  approved_at              :datetime
#  company_id               :integer
#  mobile_number            :string(255)
#  customer_param_key_1     :string(255)
#  customer_param_value_1   :string(255)
#  customer_param_key_2     :string(255)
#  customer_param_value_2   :string(255)
#  customer_param_key_3     :string(255)
#  customer_param_value_3   :string(255)
#  customer_param_key_4     :string(255)
#  customer_param_value_4   :string(255)
#  customer_param_key_5     :string(255)
#  customer_param_value_5   :string(255)
#  fetch_requirement        :string(255)
#  auto_generate_bill       :boolean          default(TRUE)
#  support_bill_validation  :string(255)
#  customer_name            :string(255)
#  customer_email           :string(255)
#  customer_aadhar_number   :string(255)
#  customer_pan             :string(255)
#

class BbpsBillerSubscription < ApplicationRecord
  include Sequenced::ActsAsSequenced
  include SoftDeletable
  
  belongs_to :biller, class_name: 'BbpsBiller'
  belongs_to :department
  belongs_to :cost_center
  belongs_to :location, class_name: 'BranchLocation'
  belongs_to :created_by_user, class_name: 'User'
  belongs_to :policy
  belongs_to :status, class_name: 'BbpsBillerSubscriptionStatus'

  validates :bbps_biller_id, presence: true
  validates :department_id, presence: true
  validates :cost_center_id, presence: true
  validates :location_id, presence: true
  validates :policy_id, presence: true
  validates :created_by_user_id, presence: true
  validates :name, presence: true
  
  acts_as_sequenced column: :subscription_id, purpose: :bbps_biller_subscription, editable: true, prefix: 'UTLTY/', min_length: 4

  # form Procurements::Bbps::Subscription::Form
  # policy Documents::Bbps::Subscription::Policy
  # state_machine Documents::Bbps::Subscription::StateMachine
  # resolver Documents::Bbps::Subscription::Policy::Scope
  # event_channel 'bbps.biller.subscription'
  # record_events 'submit', 'approve', 'show'
  # collection_events 'index'
end
