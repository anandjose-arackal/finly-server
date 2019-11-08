# == Schema Information
#
# Table name: bbps_biller_subscriptions
#
#  id                   :bigint           not null, primary key
#  bbps_biller_id       :bigint           not null
#  name                 :string(255)      not null
#  sequence_id          :string(255)      not null
#  department_id        :integer
#  cost_center_id       :integer
#  location_id          :integer
#  policy_id            :integer
#  deleted_at           :datetime
#  active               :boolean          default(TRUE)
#  note                 :text(65535)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  status_id            :integer          not null
#  user_id              :integer
#  agreement_id         :integer
#  expected_due_day     :string(255)
#  controlling_level_id :integer
#  reminder_day         :string(255)
#  biller_category_name :string(255)
#  submitted_at         :datetime
#  approved_at          :datetime
#  company_id           :integer
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
