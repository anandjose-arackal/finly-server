# == Schema Information
#
# Table name: bbps_biller_subscriptions
#
#  id                       :bigint           not null, primary key
#  bbps_biller_id           :bigint           not null
#  name                     :string(255)      not null
#  customer_params          :text(65535)
#  department_id            :integer
#  cost_center_id           :integer
#  location_id              :integer
#  policy_id                :integer
#  note                     :text(65535)
#  created_by_user_id       :integer
#  active                   :boolean          default(TRUE)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  status_id                :integer          not null
#  deleted_at               :datetime
#  subscription_id          :string(255)
#  require_poc_verification :boolean          default(TRUE)
#

class BbpsBillerSubscription < ApplicationRecord
  # include Sequenced::ActsAsSequenced
  include SoftDeletable
  
  belongs_to :biller, class_name: 'BbpsBiller', optional: true
  belongs_to :department, optional: true
  belongs_to :cost_center, optional: true
  belongs_to :location, class_name: 'BranchLocation', optional: true
  belongs_to :user, class_name: 'User', optional: true
  belongs_to :policy, optional: true
  belongs_to :status, class_name: 'BbpsBillerSubscriptionStatus', optional: true

  has_many :customer_fields, class_name: 'BbpsSubscriptionField', foreign_key: :subscription_id

  accepts_nested_attributes_for :customer_fields

  delegate :draft?, :awaiting_approval?, :retracted?, :rejected?, :approved?, :auto_approved?, :deactivated?, :reactivated?, to: :status

  # validates :bbps_biller_id, presence: true
  # validates :department_id, presence: true
  # validates :cost_center_id, presence: true
  # validates :location_id, presence: true
  # validates :policy_id, presence: true
  # # validates :created_by_user_id, presence: true
  # validates :name, presence: true
  
  # acts_as_sequenced column: :subscription_id, purpose: :bbps_biller_subscription, editable: true, prefix: 'UTLTY/', min_length: 4

  # form Procurements::Bbps::Subscription::Form
  # policy Documents::Bbps::Subscription::Policy
  # state_machine Documents::Bbps::Subscription::StateMachine
  # resolver Documents::Bbps::Subscription::Policy::Scope
  # event_channel 'bbps.biller.subscription'
  # record_events 'submit', 'approve', 'show'
  # collection_events 'index'
end
