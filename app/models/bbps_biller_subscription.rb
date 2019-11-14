# == Schema Information
#
# Table name: bbps_biller_subscriptions
#
#  id                     :bigint           not null, primary key
#  bbps_biller_id         :bigint           not null
#  name                   :string(255)      not null
#  sequence_id            :string(255)      not null
#  department_id          :integer
#  cost_center_id         :integer
#  location_id            :integer
#  policy_id              :integer
#  deleted_at             :datetime
#  active                 :boolean          default(TRUE)
#  note                   :text(65535)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  status_id              :integer          not null
#  user_id                :integer
#  agreement_id           :integer
#  expected_due_day       :string(255)
#  controlling_level_id   :integer
#  reminder_day           :string(255)
#  biller_category_name   :string(255)
#  submitted_at           :datetime
#  approved_at            :datetime
#  company_id             :integer
#  mobile_number          :string(255)
#  customer_param_key_1   :string(255)
#  customer_param_value_1 :string(255)
#  customer_param_key_2   :string(255)
#  customer_param_value_2 :string(255)
#  customer_param_key_3   :string(255)
#  customer_param_value_3 :string(255)
#  customer_param_key_4   :string(255)
#  customer_param_value_4 :string(255)
#  customer_param_key_5   :string(255)
#  customer_param_value_5 :string(255)
#

class BbpsBillerSubscription < ApplicationRecord
  # include Sequenced::ActsAsSequenced
  include SoftDeletable, Transitionable

  belongs_to :biller, class_name: 'BbpsBiller', foreign_key: :bbps_biller_id, optional: true
  belongs_to :department, optional: true
  belongs_to :cost_center, optional: true
  belongs_to :location, class_name: 'BranchLocation', optional: true
  belongs_to :user, class_name: 'User', optional: true
  belongs_to :status, class_name: 'BbpsBillerSubscriptionStatus', optional: true
  belongs_to :agreement, class_name: 'PaymentAgreement', optional: true

  has_many :customer_fields, class_name: 'BbpsSubscriptionField', foreign_key: :subscription_id
  has_many :subscription_pocs, class_name: 'BbpsSubscriptionPoc', foreign_key: :subscription_id

  has_many :pocs, class_name: 'User', through: :subscription_pocs, source: :user
  has_many :bbps_bills, class_name: 'BbpsBill'

  after_update :cleanup # Destroy Biller Subscription fields for other billers if any

  # accepts_nested_attributes_for :customer_fields

  delegate :draft?, :awaiting_approval?, :retracted?, :rejected?, :approved?, :auto_approved?, :deactivated?, :reactivated?, to: :status

  # resolver BBPSubscriptionResolver
  # state_machine WorkManager
  #
  # BbpsBillerSubscription.resolve(@user, {role_id: :manager}, include: {puchase_order: [:amount]})

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


  default_scope {order('bbps_biller_subscriptions.created_at DESC')}

  scope :filter_status, -> (status) {
    case status
    when 'approved', :approved
      where(status_id: BbpsBillerSubscriptionStatus.id_for(:approved))
    end
  }

  scope :includes_for_index, -> {
    includes(:pocs)
  }

  scope :filter_department_id, -> (id) {
    where(department_id: id)
  }

  scope :filter_cost_center_id, -> (id) {
    where(cost_center_id: id)
  }

  scope :filter_policy_id, -> (id) {
    where(policy_id: id)
  }

  scope :filter_location_id, -> (id) {
    where(location_id: id)
  }

  def cleanup
    self.customer_fields.without_biller_id(bbps_biller_id).destroy_all
  end

  def as_json(options={})
    {
        id: id,
        biller: biller.as_json({index: true}),
        name: name,
        sequence_id: sequence_id,
        department: department.as_json,
        cost_center: cost_center.as_json,
        location: location.as_json,
        policy: policy.as_json,
        active: active,
        note: note,
        created_at: created_at.strftime("%d-%b-%Y"),
        updated_at: updated_at.strftime("%d-%b-%Y"),
        status: status.as_json,
        user: user&.json_for_trail,
        biller_category_name: biller_category_name,
        customer_param_key_1: customer_param_key_1,
        customer_param_value_1: customer_param_value_1,
        customer_param_key_2: customer_param_key_2,
        customer_param_value_2: customer_param_value_2,
        customer_param_key_3: customer_param_key_3,
        customer_param_value_3: customer_param_value_3,
        customer_param_key_4: customer_param_key_4,
        customer_param_value_4: customer_param_value_4,
        customer_param_key_5: customer_param_key_5,
        customer_param_value_5: customer_param_value_5,
        customer_fields: customer_fields.as_json,
        subscription_pocs: subscription_pocs.as_json
    }
  end

  def self.document_owner_attribute
    'user_id'
  end

  def self.document_status_attribute
    'status_id'
  end

  def self.document_status_class_name
    'BbpsBillerSubscriptionStatus'
  end

  def self.roles
    [
        :utility_bill_master_initator,
        :utility_bill_master_reviewer,
        :utility_bill_initator,
        :utility_bill_reviewer,
        :bank_payment_request_initiator,
        :bank_payment_request_reviewer,
        :bank_payment_request_creditor,
        :bank_payment_request_auditor
    ]
  end

  def self.status_ids(*statuses)
    status_ids = []
    statuses.each do |status|
      status_ids.push BbpsBillerSubscriptionStatus.id_for(status)
    end

    status_ids.reject {|status_id| status_id.nil?}
  end

  def self.open_statuses
    self.status_ids(:draft, :retracted, :rejected)
  end


end
