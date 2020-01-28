# == Schema Information
#
# Table name: bbps_biller_subscriptions
#
#  id                      :bigint           not null, primary key
#  bbps_biller_id          :bigint           not null
#  name                    :string(255)      not null
#  sequence_id             :string(255)      not null
#  department_id           :integer
#  cost_center_id          :integer
#  location_id             :integer
#  policy_id               :integer
#  deleted_at              :datetime
#  active                  :boolean          default(TRUE)
#  note                    :text(65535)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  status_id               :integer          not null
#  user_id                 :integer
#  agreement_id            :integer
#  expected_bill_day       :string(255)
#  controlling_level_id    :integer
#  reminder_before_days    :string(255)
#  biller_category_name    :string(255)
#  submitted_at            :datetime
#  approved_at             :datetime
#  company_id              :integer
#  mobile_number           :string(255)
#  customer_param_key_1    :string(255)
#  customer_param_value_1  :string(255)
#  customer_param_key_2    :string(255)
#  customer_param_value_2  :string(255)
#  customer_param_key_3    :string(255)
#  customer_param_value_3  :string(255)
#  customer_param_key_4    :string(255)
#  customer_param_value_4  :string(255)
#  customer_param_key_5    :string(255)
#  customer_param_value_5  :string(255)
#  fetch_requirement       :string(255)
#  auto_generate_bill      :boolean          default(TRUE)
#  support_bill_validation :string(255)
#  customer_name           :string(255)
#  customer_email          :string(255)
#  customer_aadhar_number  :string(255)
#  customer_pan            :string(255)
#  tax_rate_id             :integer
#  category_id             :integer
#  hsn_sac                 :string(255)
#  quick_pay               :string(255)      default("N")
#  last_paid_at            :datetime
#

class BbpsBillerSubscription < ApplicationRecord
  include Sequenced::ActsAsSequenced
  include SoftDeletable, Transitionable

  acts_as_sequenced column: :sequence_id, purpose: :bbps_biller_subscription, editable: false, prefix: 'UBM'

  belongs_to :biller, class_name: 'BbpsBiller', foreign_key: :bbps_biller_id, optional: true
  belongs_to :company
  belongs_to :department, optional: true
  belongs_to :cost_center, optional: true
  belongs_to :location, class_name: 'BranchLocation', optional: true
  belongs_to :user, class_name: 'User', optional: true
  belongs_to :status, class_name: 'BbpsBillerSubscriptionStatus', optional: true
  belongs_to :agreement, class_name: 'PaymentAgreement', optional: true

  belongs_to :category, class_name: 'Category', optional: true
  belongs_to :tax_rate, class_name: 'TaxRate', optional: true

  has_many :customer_fields, class_name: 'BbpsSubscriptionField', foreign_key: :subscription_id
  has_many :subscription_pocs, class_name: 'BbpsSubscriptionPoc', foreign_key: :subscription_id

  has_many :pocs, class_name: 'User', through: :subscription_pocs, source: :user
  has_many :bbps_bills, class_name: 'BbpsBill', foreign_key: :subscription_id
  has_many :attachments, as: :resource, dependent: :destroy

  after_update :cleanup # Destroy Biller Subscription fields for other billers if any

  delegate :draft?, :awaiting_approval?, :retracted?, :rejected?, :approved?, :auto_approved?, :deactivated?, :reactivated?, to: :status


  default_scope {order('bbps_biller_subscriptions.created_at DESC')}

  scope :filter_status, -> (status, user = nil) {
    case status
    when 'approved', :approved
      where(status_id: BbpsBillerSubscriptionStatus.id_for(:approved))
    when 'processing', :processing
      where(status_id: BbpsBillerSubscriptionStatus.id_for(:awaiting_approval))
    when 'draft', :draft
      where(status_id: BbpsBillerSubscriptionStatus.ids_for(:draft, :retracted, :rejected))
    when 'deactivated', :deactivated
      where(status_id: BbpsBillerSubscriptionStatus.id_for(:deactivated))
    when 'reactivated', :reactivated
      where(status_id: BbpsBillerSubscriptionStatus.id_for(:reactivated))
    when 'awaiting_approval', :awaiting_approval
      # if user.present?
      # BbpsBillerSubscription.awaiting_action_items(user)
      awaiting_action_items(RequestStore.store[:current_user]&.id)
      # end
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

  scope :filter_user_id, -> (id) {
    where(user_id: id)
  }

  scope :filter_biller_id, -> (id) {
    where(bbps_biller_id: id)
  }

  scope :filter_biller_type, -> (biller_type) {
    joins(:biller).where("bbps_billers.biller_category_name = ?", "#{biller_type}")
  }

  def cleanup
    self.customer_fields.without_biller_id(bbps_biller_id).destroy_all
  end

  def as_json(options={})
    {
        id: id,
        biller: biller.as_json({index: true}),
        name: name,
        mobile_number: mobile_number,
        sequence_id: sequence_id,
        department: department.as_json,
        cost_center: cost_center.as_json,
        location: location.as_json,
        policy: policy.as_json,
        category: category.as_json,
        tax_rate: tax_rate.as_json,
        hsn_sac: hsn_sac,
        active: active,
        auto_fetchable: auto_fetchable,
        note: note,
        created_at: created_at.strftime("%d-%b-%Y"),
        updated_at: updated_at.strftime("%d-%b-%Y"),
        status: status.as_json,
        user: user&.json_for_trail,
        biller_category_name: biller_category_name,
        customer_fields: all_customer_fields,
        subscription_pocs: subscription_pocs.as_json,
        fetch_requirement: fetch_requirement,
        support_bill_validation: support_bill_validation,
        auto_generate_bill: auto_generate_bill,
        expected_bill_day: expected_bill_day,
        reminder_before_days: reminder_before_days,
        customer_email: customer_email,
        customer_name: customer_name,
        last_paid_at: last_paid_at&.strftime("%I:%M %p, %d %b %Y"),
        customer_pan: customer_pan
    }
  end

  def auto_fetchable
    return true if ["MANDATORY", "OPTIONAL"].include? self.biller.fetch_requirement
    false
  end

  def all_customer_fields
    fields = []
    5.times do |j|
      customer_params_config = biller.biller_customer_params[j]
      customer_param_present = self.send("customer_param_key_#{j + 1}").present?
      data = {
          "customer_param_key_#{j + 1}" => self.send("customer_param_key_#{j + 1}"),
          "customer_param_value_#{j + 1}" => self.send("customer_param_value_#{j + 1}"),
          "key_label" => ("customer_param_key_#{j + 1}" if customer_param_present),
          "index" => j + 1,
          "value_label" => ("customer_param_value_#{j + 1}" if customer_param_present),
          "display" => customer_param_present
      }

      data.merge!(customer_params_config) if customer_param_present and customer_params_config.present?

      fields << data
    end

    fields
  end

  # display_name  used  in  payment  file  creation method to  print the  beneficiary name
  def display_name
      self.biller&.biller_name
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

  def role_based_initiator_associated_items(user, role_id, options = {})
    if [UserRole.id_for(:utility_bill_master_initiator)].include?(role_id)
      super
    elsif [UserRole.id_for(:utility_bill_initiator)].include?(role_id)
      ids = BbpsBill.role_based_initiator_associated_items(user, role_id).pluck(:subscription_id)
      where(id: ids)
    elsif role_id == UserRole.id_for(:bank_payment_request_initiator)
      role_based_creditor_associated_items(user, role_id)
    end
  end

  def self.role_based_associated_status_ids(user)
    BbpsBillerSubscriptionStatus.ids_for(self.role_based_statuses(user))
  end

  def self.role_based_statuses(user)
    statuses = []
    if user.policy_user_roles.pluck(:user_role_id).uniq.present?
      user.policy_user_roles.pluck(:user_role_id).uniq.each do |role_id|
        if UserRole.ids_for(:bank_payment_request_initiator, :bank_payment_request_reviewer, :bank_payment_request_auditor, :bank_payment_request_creditor).include?(role_id.to_i)
          statuses += [:approved, :auto_approved, :deactivated, :reactivated]
        elsif UserRole.id_for(:utility_bill_master_initiator) == role_id.to_i
          statuses += [:draft, :awaiting_approval, :retracted, :rejected, :approved, :auto_approved, :deactivated, :reactivated]
        elsif UserRole.id_for(:utility_bill_master_reviewer) == role_id.to_i
          statuses += [:awaiting_approval, :retracted, :rejected, :approved, :auto_approved, :deactivated, :reactivated]
        elsif UserRole.ids_for(:utility_bill_initiator, :utility_bill_reviewer).include?(role_id.to_i)
          statuses += [:approved, :auto_approved, :deactivated, :reactivated]
        elsif UserRole.id_for(:admin) == role_id.to_i
          statuses += [:awaiting_approval, :retracted, :rejected, :approved, :auto_approved, :deactivated, :reactivated]
        end
      end
    end
    return statuses.uniq
  end

  def self.open_status_ids(user)
    BbpsBillerSubscriptionStatus.ids_for([:draft])
  end

  def self.finance_associated_status_ids
    BbpsBillerSubscriptionStatus.ids_for([:approved, :auto_approved, :reactivated, :deactivated])
  end

  def self.auditor_associated_status_ids
    BbpsBillerSubscriptionStatus.ids_for([:approved, :auto_approved, :awaiting_approval, :rejected, :retracted, :reactivated, :deactivated])
  end

  def self.roles
    [
        :utility_bill_master_initiator,
        :utility_bill_master_reviewer,
        :utility_bill_initiator,
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

  def self.human_name(options = {})
    options[:plural] ? 'Utility Bill Masters' : 'Utility Bill Master'
  end
end
