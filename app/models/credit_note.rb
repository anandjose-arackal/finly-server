# == Schema Information
#
# Table name: credit_notes
#
#  id                            :bigint           not null, primary key
#  company_id                    :integer
#  user_id                       :integer
#  invoice_id                    :integer
#  procurement_id                :integer
#  status_id                     :integer
#  controlling_level_id          :integer
#  policy_id                     :integer
#  vendor_id                     :integer
#  shipping_location_id          :integer
#  billing_location_id           :integer
#  sequence_id                   :string(255)
#  credit_note_date              :date
#  narration                     :text(65535)
#  billing_address               :text(65535)
#  shipping_address              :text(65535)
#  gross_receivable_amount_id    :integer
#  tax_amount_id                 :integer
#  discount_amount_id            :integer
#  net_receivable_amount_id      :integer
#  tds_rate_id                   :integer
#  tds_amount_id                 :integer
#  freight_amount_id             :integer
#  previously_adjusted_amount_id :integer
#  net_adjustable_amount_id      :integer
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  deleted_at                    :datetime
#  roundoff_amount_id            :integer
#  department_id                 :integer
#  cost_center_id                :integer
#  submitted_at                  :datetime
#  approved_at                   :datetime
#  credit_note_number            :string(255)
#  last_adjusted_at              :datetime
#  review_note                   :text(65535)
#  erp_sync_status_id            :integer
#  erp_sync_message              :text(65535)
#  erp_sync_reference_id         :string(255)
#  erp_sync_attempts_count       :integer          default("0")
#  erp_sync_attempted_at         :datetime
#  base_currency_id              :integer
#  reporting_currency_id         :integer
#

class CreditNote < ApplicationRecord
  attr_accessor :skip_callback
  include SoftDeletable, Templatable, Transitionable, MathUtil, CustomFieldFilterSupport, GetCurrency
  include Sequenced::ActsAsSequenced
  include EventProducer
  include Concerns::ErpSyncConcern
  include ErpSyncable
  include FormsHelper

  acts_as_sequenced column: :sequence_id, purpose: :credit_note, editable: false, prefix: 'CN'

  attr_accessor :skip_callback

  belongs_to :company, optional: true
  belongs_to :user, optional: true
  belongs_to :created_by, class_name: 'User', optional: true, foreign_key: :user_id
  belongs_to :status, class_name: "CreditNoteStatus", optional: true
  belongs_to :invoice, optional: true
  belongs_to :procurement, optional: true
  belongs_to :vendor, class_name: 'YesBankVendor', optional: true
  belongs_to :shipping_location, class_name: 'BranchLocation', optional: true
  belongs_to :billing_location, class_name: 'BranchLocation', optional: true
  belongs_to :tds_rate, class_name: 'TdsRatesList', optional: true
  belongs_to :department, class_name: 'Department', optional: true
  belongs_to :cost_center, class_name: 'CostCenter', optional: true

  belongs_to :gross_receivable_amount, class_name: 'Amount', optional: true
  belongs_to :tax_amount, class_name: 'Amount', optional: true
  belongs_to :discount_amount, class_name: 'Amount', optional: true
  belongs_to :net_receivable_amount, class_name: 'Amount', optional: true
  belongs_to :tds_amount, class_name: 'Amount', optional: true
  belongs_to :freight_amount, class_name: 'Amount', optional: true
  belongs_to :previously_adjusted_amount, class_name: 'Amount', optional: true
  belongs_to :net_adjustable_amount, class_name: 'Amount', optional: true
  belongs_to :base_currency, optional: true, class_name: 'Currency'
  belongs_to :reporting_currency, optional: true, class_name: 'Currency'

  belongs_to :tds_rate, class_name: 'TdsRatesList', optional: true
  belongs_to :vendor_country, optional: true, class_name: 'Country'

  has_many :items, class_name: 'CreditNoteItem', dependent: :destroy
  has_many :adjustments, class_name: 'CreditNoteAdjustment' #, dependent: :destroy
  has_many :comments, class_name: 'ProcurementComment', as: :parent_commentable
  has_many :attachments, class_name: "ProcurementAttachment", as: :procurement_document
  has_many :form_custom_fields, class_name: 'FormCustomField', as: :document, dependent: :destroy

  # before_save :calculate_amount
  after_create :calculate_from_items_values, unless: :skip_callback
  before_save :calculate_from_item_methods
  after_save :set_currency_for_amount, unless: :skip_callback
  after_touch :update_adjustments
  before_create :set_currency
  after_save :sync_to_old_forms

  delegate :draft?, :awaiting_approval?, :retracted?, :rejected?, :approved?, :auto_approved?, :voided?, :adjusted?, :partially_adjusted?, :unadjusted?, to: :status

  def set_currency
    self.reporting_currency_id = self.company.reporting_currency.id if self.reporting_currency_id.blank?
    self.base_currency_id = self.company.reporting_currency.id if self.base_currency_id.blank?
  end

  def as_json(options = {})
    if options[:index]
      data = {
          id: id,
          sequence_id: sequence_id,
          procurement_id: procurement_id,
          credit_note_number: credit_note_number,
          status_name: status&.name,
          status_id: status&.id,
          narration: narration,
          credit_note_date: credit_note_date,
          created_at: created_at.strftime('%d %b %Y'),
          updated_at: updated_at.strftime('%d %b %Y'),
          invoice_number: invoice&.invoice_number,
          vendor_name: vendor.display_name,
          vendor_id: vendor.id,
          department_name: department&.name,
          department_id: department&.id,
          cost_center_name: cost_center&.name,
          cost_center_id: cost_center&.id,
          policy_name: policy&.name,
          policy_id: policy&.id,
          user_name: user&.name,
          user_email: user&.email,
          user_employee_id: user.employee_id,
          previously_adjusted_amount: previously_adjusted_amount.as_json({rounded: true}),
          net_adjustable_amount: net_adjustable_amount.as_json({rounded: true}),
          base_currency: get_base_currency,
          reporting_currency: get_reporting_currency,
          forms_enabled: forms_enabled
      }
    else
      data = {
        id: id,
        procurement_id: procurement_id,
        status: status.as_json,
        credit_note_number: credit_note_number,
        sequence_id: sequence_id,
        # gst_type_id: gst_type_id,
        credit_note_date: credit_note_date,
        created_at: created_at.strftime('%d %b %Y'),
        updated_at: updated_at.strftime('%d %b %Y'),
        invoice_number: invoice&.invoice_number,
        rcm_enabled: invoice&.rcm_enabled,
        attachments: attachments.as_json,
        vendor: vendor.as_json,
        shipping_location: shipping_location.as_json,
        billing_location: billing_location.as_json,
        billing_address: billing_address,
        narration: narration,
        shipping_address: shipping_address,
        vendor_location: invoice&.gstin_location&.as_json,
        cost_center: cost_center.as_json,
        department: department.as_json,
        policy: policy.as_json,
        items: items.as_json,
        gross_receivable_amount: gross_receivable_amount.as_json,
        after_tax_amount: after_tax_amount,
        tax_amount: tax_amount.as_json,
        tds_rate_id: tds_rate_id,
        tds_code: tds_rate&.name,
        tds_amount: tds_amount.as_json,
        net_receivable_amount: net_receivable_amount.as_json,
        freight_amount: freight_amount.as_json,
        previously_adjusted_amount: previously_adjusted_amount.as_json,
        net_adjustable_amount: net_adjustable_amount.as_json,
        user: user.as_json,
        invoice_gst_type: tax_type_name,
        approved_at: approved_at&.strftime('%d %b %Y'),
        base_currency: get_base_currency,
        reporting_currency: get_reporting_currency,
        forms_enabled: (options[:macro] ? "" : forms_enabled)
      } 
    end

    return data
  end

  def after_tax_amount
    data = {
        currency: gross_receivable_amount&.currency.as_json,
    }

    if self.invoice&.rcm_enabled
      data[:value] = gross_receivable_amount&.value.to_f
    else
      data[:value] = precision_value(gross_receivable_amount&.value.to_f + tax_amount&.value.to_f)
    end

    data
  end

  scope :filter_status, -> (status) {
    case status
    when 'draft', :draft
      where(status_id: CreditNoteStatus.id_for(:draft))
    when 'retracted', :retracted
      where(status_id: CreditNoteStatus.id_for(:retracted))
    when 'rejected', :rejected
      where(status_id: CreditNoteStatus.id_for(:rejected))
    when 'processing', :processing
      where(status_id: CreditNoteStatus.id_for(:awaiting_approval))
    when 'awaiting_approval', :awaiting_approval
      awaiting_action_items(RequestStore.store[:current_user]&.id)
    when 'approved', :approved
      where(status_id: CreditNoteStatus.id_for(:approved))
    when 'auto_approved', :auto_approved
      where(status_id: CreditNoteStatus.id_for(:auto_approved))
    when 'partially_adjusted', :partially_adjusted
      where(status_id: CreditNoteStatus.id_for(:partially_adjusted))
    when 'unadjusted', :unadjusted
      where(status_id: CreditNoteStatus.id_for(:unadjusted))
    when 'adjusted', :adjusted
      where(status_id: CreditNoteStatus.id_for(:adjusted))
    when 'voided', :voided
      where(status_id: CreditNoteStatus.id_for(:voided))
    else
      # do nothing
    end
  }

  scope :with_id, -> (id) {
    where id: id
  }

  scope :sort_for_index, -> {
    reorder('credit_notes.created_at DESC')
  }

  scope :includes_for_index, -> {
    includes(:invoice, :vendor, :department, :cost_center, :policy, :status, net_adjustable_amount: [:currency], previously_adjusted_amount: [:currency])
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
    where(shipping_location_id: id).or(where(billing_location_id: id))
  }

  scope :filter_invoice_id, -> (id) {
    where(invoice_id: id)
  }

  scope :filter_sequence_id, -> (id) {
    where("credit_notes.sequence_id like ?", "%#{id}%")
  }

  scope :filter_invoice_sequence_id, -> (id) {
    joins(:invoice).where("invoices.invoice_id like ?", "%#{id}%")
  }

  scope :filter_invoice_number, -> (invoice_number) {
    joins(:invoice).where("invoices.invoice_number like ?", invoice_number)
  }

  scope :filter_vendor_id, -> (vendor_id) {
    where(vendor_id: vendor_id)
  }

  scope :filter_adjustables, -> (enabled = true) {
    joins(:net_adjustable_amount).where("amounts.value > ?", 0).where(status_id: CreditNoteStatus.ids_for(:approved, :auto_approved, :partially_adjusted, :unadjusted))
  }

  scope :filter_date, -> (start_date, end_date) { where('credit_note_date >= ? AND credit_note_date =< ? ', Date.parse(start_date), Date.parse(end_date)) }
  scope :filter_created_on_date, -> (start_date, end_date) { where("created_at >= ? AND created_at <= ?", Date.parse(start_date).beginning_of_day, Date.parse(end_date).end_of_day) }
  scope :filter_approved_on_date, -> (start_date, end_date) { where("approved_at >= ? AND approved_at <= ?", Date.parse(start_date).beginning_of_day, Date.parse(end_date).end_of_day) }

  scope :filter_amount, -> (gteq, lteq) do
    gteq = gteq.to_f
    lteq = lteq.present? ? lteq.to_f : 9999999999999999

    joins(:amount).where("value >= ? AND value <= ?", gteq, lteq)
  end

  scope :order_previously_adjustable_amount, -> (order_type = "ASC") {
    order_type = format_order_type(order_type)
    # nosqli - The substituted string is force formatted through the function call to format_order_type, not other value other than "ASC" or "DESC" possible
    joins(:previously_adjusted_amount).reorder("amounts.value #{order_type}")
  }

  scope :order_net_adjustable_amount, -> (order_type = "ASC") {
    order_type = format_order_type(order_type)
    # nosqli - The substituted string is force formatted through the function call to format_order_type, not other value other than "ASC" or "DESC" possible
    joins(:net_adjustable_amount).reorder("amounts.value #{order_type}")
  }

  scope :order_created_at, -> (order_type = "ASC") {
    order_type = format_order_type(order_type)
    # nosqli - The substituted string is force formatted through the function call to format_order_type, not other value other than "ASC" or "DESC" possible
    reorder("credit_notes.created_at #{order_type}")
  }

  scope :with_status_id, -> (status_id) {
    case status_id
    when 90
      where status_id: CreditNoteStatus.ids_for(:draft, :retracted)
    when 91
      awaiting_action_items(RequestStore.store[:current_user]&.id)
    when 92
      where status_id: CreditNoteStatus.ids_for(:approved, :auto_approved, :partially_adjusted, :unadjusted)
    else
      where status_id: status_id
    end
  }
  scope :with_status_ids, -> (status_id) {
    with_status_id(status_id)
  }

  scope :pending_erp_sync, -> (*args) {
    with_erp_sync_status_pending.
        where(status_id: CreditNoteStatus.ids_for(:approved, :auto_approved, :partially_adjusted, :unadjusted))
  }

  ransack_scopes :with_status_id
  ransack_scopes :with_status_ids

  def self.format_order_type(order_type)
    order_type = "ASC" unless ["ASC", "DESC"].include?(order_type.to_s.upcase)
    order_type
  end


  # Transitionable Methods #

  def validate_if_auditor(user)
    policy = Policy.find_by id: self.policy_id
    if policy.present? && policy.policy_user_roles.present?
      policy.policy_user_roles.where(user_role_id: UserRole.id_for(:credit_note_auditor), user_id: user.id).present? rescue false
    end
  end

  def gstin_location
    self.invoice&.gstin_location
  end

  def  tax_type_name
    case self.invoice&.gst_type_id
    when GstType.id_for(:cgst_sgst)
      'CGST + SGST'
    when GstType.id_for(:igst)
      'IGST'
    else
      nil
    end
  end

  def self.document_owner_attribute
    'user_id'
  end

  def self.document_status_attribute
    'status_id'
  end

  def self.document_status_class_name
    'CreditNoteStatus'
  end

  def self.role_based_associated_status_ids(user)
    CreditNoteStatus.ids_for(self.role_based_statuses(user))
  end


  def self.role_based_statuses(user)
    statuses = []
    if user.policy_user_roles.pluck(:user_role_id).uniq.present?
      user.policy_user_roles.pluck(:user_role_id).uniq.each do |role_id|
        if [UserRole.id_for(:credit_note_initiator)]
          statuses += [:draft, :retracted, :awaiting_approval, :approved, :rejected, :auto_approved, :voided, :adjusted, :partially_adjusted, :unadjusted]
        elsif [UserRole.id_for(:credit_note_reviewer)]
          statuses += [:retracted, :awaiting_approval, :approved, :rejected, :voided, :adjusted, :partially_adjusted, :unadjusted]
        elsif UserRole.ids_for(:purchase_order_initiator,
                               :purchase_order_reviewer,
                               :purchase_order_auditor,
                               :po_invoice_initiator,
                               :po_invoice_reviewer,
                               :po_invoice_auditor,
                               :non_po_invoice_initiator,
                               :non_po_invoice_reviewer,
                               :non_po_invoice_auditor,
                               :bank_payment_request_initiator,
                               :bank_payment_request_reviewer,
                               :bank_payment_request_auditor,
                               :bank_payment_request_creditor,
        ).include?(role_id)
          status_ids += [:approved, :auto_approved, :voided, :adjusted, :partially_adjusted, :unadjusted]
        elsif UserRole.id_for(:admin) == role_id.to_i
          statuses += [:retracted, :awaiting_approval, :approved, :rejected, :auto_approved, :voided, :adjusted, :partially_adjusted, :unadjusted]
        end
      end
    end
    return statuses.uniq
  end

  def retrieve_value(entity)
    send("#{entity.entity_key.gsub('_id', '')}")&.name rescue send(entity.entity_key)
  end

  def form_klass
    Forms::Router.klass(:credit_notes)&.name
  end

  def self.open_status_ids(user)
    CreditNoteStatus.ids_for(:draft)
  end

  def self.finance_associated_status_ids
    CreditNoteStatus.ids_for(:approved, :auto_approved, :voided, :adjusted, :partially_adjusted, :unadjusted)
  end

  def self.auditor_associated_status_ids
    CreditNoteStatus.ids_for([:approved, :auto_approved, :awaiting_approval, :rejected, :retracted, :voided])
  end

  def self.role_based_initiator_associated_items(user, role_id, options = {})
    if UserRole.id_for(:credit_note_initiator) == role_id
      super
    elsif UserRole.ids_for(:purchase_order_initiator,
                           :purchase_order_reviewer,
                           :purchase_order_auditor,
                           :po_invoice_initiator,
                           :po_invoice_reviewer,
                           :po_invoice_auditor,
                           :non_po_invoice_initiator,
                           :non_po_invoice_reviewer,
                           :non_po_invoice_auditor,
                           :bank_payment_request_initiator,
                           :bank_payment_request_reviewer,
                           :bank_payment_request_auditor,
                           :bank_payment_request_creditor,
    ).include?(role_id)
      policy_ids = user.policy_user_roles.where(user_role_id: role_id).pluck(:policy_id).uniq rescue nil
      # Find all Credit notes post approved state in the respective policies
      where(policy_id: policy_ids).where(status_id: CreditNoteStatus.ids_for(:approved, :auto_approved, :partially_adjusted, :unadjusted, :adjusted, :voided))
    else
      # Nothing
    end
  end

  def self.role_based_reviewer_associated_items(user, role_id, options = {})
    if UserRole.id_for(:credit_note_reviewer) == role_id
      super
    else
      role_based_initiator_associated_items(user, role_id)
    end
  end

  def self.roles
    [
        :purchase_order_initiator,
        :purchase_order_reviewer,
        :purchase_order_auditor,
        :po_invoice_initiator,
        :po_invoice_reviewer,
        :po_invoice_auditor,
        :non_po_invoice_initiator,
        :non_po_invoice_reviewer,
        :non_po_invoice_auditor,
        :credit_note_initiator,
        :credit_note_reviewer,
        :credit_note_auditor,
        :bank_payment_request_initiator,
        :bank_payment_request_reviewer,
        :bank_payment_request_creditor,
        :bank_payment_request_auditor
    ]
  end

  def self.status_ids(*statuses)
    status_ids = []
    statuses.each do |status|
      status_ids.push CreditNoteStatus.id_for(status)
    end

    status_ids.reject { |status_id| status_id.nil? }
  end

  def self.open_statuses
    self.status_ids(:draft, :retracted, :rejected)
  end

  # Used for tracking completion %
  def review_pending?
    CreditNoteStatus.ids_for(:draft, :retracted, :rejected).include?(status_id)
  end

  def review_completed?
    CreditNoteStatus.ids_for(:approved, :auto_approved, :partially_adjusted, :adjusted, :voided, :unadjusted).include?(status_id)
  end

  def review_in_progress?
    CreditNoteStatus.ids_for(:awaiting_approval).include?(status_id)
  end

  def name
    self.sequence_id
  end

  def forms_enabled
    CreditNoteToggle.new(RequestStoreUtil.current_user).enabled? ? 'true' : 'false'   #TODO: check why it's string
  end

  def update_adjustments
    update_adjustable_amount
    sync_to_old_forms
    update_status
  end

  def sync_to_old_forms
    if self.forms_enabled == 'true'
      self.amounts_attributes_map.each do |key, value|
        amount_value = self.send("#{key}")
        amount_attr = self.send("#{value}_id")
        base_currency_id = self.get_base_currency&.id
        if amount_attr.present?
          Amount.find_by(id: amount_attr).update(value: amount_value, currency_id: base_currency_id)
        else
          self.assign_attributes(
            {
              "#{value}_id": Amount.create(value: amount_value, currency_id: base_currency_id).id
            }
          )
        end
      end
    end
  end

  def amounts_attributes_map
    {
      cn_gross_receivable_amount: 'gross_receivable_amount',
      cn_tax_amount: 'tax_amount',
      cn_net_receivable_amount: 'net_receivable_amount',
      cn_tds_amount: 'tds_amount',
      cn_previously_adjusted_amount: 'previously_adjusted_amount',
      cn_net_adjustable_amount: 'net_adjustable_amount'
    }
  end

  def controlling_user
    self.get_reviewers&.first
  end

  def creator
    self.user
  end

  private

  def calculate_from_items_values
    currency_id = self&.base_currency_id || 1

    # Gross Receivable Amount
    # Only picks from the items where item type is QTY Change / Price Drop
    gross_receivable_amount_value = items.
        filter { |item| CreditNoteItemType.ids_for(:qty_change, :price_drop).include?(item.credit_note_item_type_id) }.
        map { |item| item.taxable_amount&.value }.compact.sum

    gross_receivable_amount_value = precision_value(gross_receivable_amount_value)


    if gross_receivable_amount.present?
      gross_receivable_amount.update(value: gross_receivable_amount_value)
    else
      self.gross_receivable_amount = Amount.create(value: gross_receivable_amount_value, currency_id: currency_id)
    end

    # Tax Amount (GST)
    tax_amount_value = items.map { |item| item.tax_amount&.value }.compact.sum
    if tax_amount.present?
      tax_amount.update(value: tax_amount_value)
    else
      self.tax_amount = Amount.create(value: tax_amount_value, currency_id: currency_id)
    end

    # Where TDS Applicable is yes
    # Only picks from the items where item type is QTY Change / Price Drop
    tds_applicable_amount = items.
        filter { |item| item.tds_applicable? and CreditNoteItemType.ids_for(:qty_change, :price_drop).include?(item.credit_note_item_type_id) }.
        map { |item| item.taxable_amount&.value }.compact.sum
    tds_amount_value = 0
    tds_rate_percentage = tds_rate&.tds
    if tds_rate_percentage.present?
      tds_amount_value = tds_applicable_amount * tds_rate_percentage / 100

      if self.tds_amount.present?
        self.tds_amount.update(value: tds_amount_value)
      else
        self.tds_amount = Amount.create(value: tds_amount_value, currency_id: currency_id)
      end
    end

    if self.invoice.rcm_enabled
      net_receivable_amount_value = precision_value(gross_receivable_amount_value - tds_amount_value)
    else
      net_receivable_amount_value = precision_value(gross_receivable_amount_value + tax_amount_value - tds_amount_value)
    end

    if self.net_receivable_amount.present?
      self.net_receivable_amount.update(value: net_receivable_amount_value)
    else
      self.net_receivable_amount = Amount.create(value: net_receivable_amount_value, currency_id: currency_id)
    end

    update_adjustable_amount
    self.skip_callback = true
    self.save(validation: false)
  end

  def calculate_from_item_methods
    currency_id = self&.get_base_currency.id || 1

    # Gross Receivable Amount
    # gross_receivable_amount_value = items.map {|item| item.taxable_amount&.value}.compact.sum
    # Only picks from the items where item type is QTY Change / Price Drop
    gross_receivable_amount_value = items.
        filter { |item| CreditNoteItemType.ids_for(:qty_change, :price_drop).include?(item.credit_note_item_type_id) }.
        map(&:get_taxable_amount).compact.sum


    if gross_receivable_amount.present?
      gross_receivable_amount.update(value: gross_receivable_amount_value)
    else
      self.gross_receivable_amount = Amount.create(value: gross_receivable_amount_value, currency_id: currency_id)
    end

    # Tax Amount (GST)
    # tax_amount_value = items.map {|item| item.tax_amount&.value}.compact.sum
    tax_amount_value = items.map(&:get_tax_amount).compact.sum
    if tax_amount.present?
      tax_amount.update(value: tax_amount_value)
    else
      self.tax_amount = Amount.create(value: tax_amount_value, currency_id: currency_id)
    end

    # Where TDS Applicable is yes
    # Only picks from the items where item type is QTY Change / Price Drop
    tds_applicable_amount = items.
        filter { |item| item.tds_applicable? and CreditNoteItemType.ids_for(:qty_change, :price_drop).include?(item.credit_note_item_type_id) }.
        map(&:get_taxable_amount).compact.sum

    tds_amount_value = 0
    tds_rate_percentage = tds_rate&.tds
    if tds_rate_percentage.present?
      tds_amount_value = tds_applicable_amount * tds_rate_percentage / 100
      # tds_amount_value = tds_amount_value.round(-1) # round the tds to the nearest 10. This is as per income tax rules to calculate tds, section 288b
      tds_amount_value = tds_amount_value.ceil # round the tds to the nearest digit as of now.

      if self.tds_amount.present?
        self.tds_amount.update(value: tds_amount_value)
      else
        self.tds_amount = Amount.create(value: tds_amount_value, currency_id: currency_id)
      end
    end

    if self.invoice.rcm_enabled
      net_receivable_amount_value = precision_value(gross_receivable_amount_value - tds_amount_value)
    else
      net_receivable_amount_value = precision_value(gross_receivable_amount_value + tax_amount_value - tds_amount_value)
    end

    if self.net_receivable_amount.present?
      self.net_receivable_amount.update(value: net_receivable_amount_value)
    else
      self.net_receivable_amount = Amount.create(value: net_receivable_amount_value, currency_id: currency_id)
    end

    update_adjustable_amount
  end

  def update_adjustable_amount
    currency_id = net_receivable_amount.currency_id
    previously_adjusted_amount_value = precision_value(adjustments.joins(:amount).sum(:value))

    if self.previously_adjusted_amount.present?
      self.previously_adjusted_amount.update(value: previously_adjusted_amount_value)
    else
      self.previously_adjusted_amount = Amount.create(value: previously_adjusted_amount_value, currency_id: currency_id)
    end

    net_adjustable_amount_value = precision_value(net_receivable_amount&.value&.to_f - previously_adjusted_amount_value)
    if self.net_adjustable_amount.present?
      self.net_adjustable_amount.update(value: net_adjustable_amount_value)
    else
      self.net_adjustable_amount = Amount.create(value: net_adjustable_amount_value, currency_id: currency_id)
    end
    if self.forms_enabled == 'true'
      previously_adjusted_amount_value = precision_value(adjustments.sum(:cn_adjustment_amount)).to_f
      net_adjustable_amount_value = [precision_value(cn_net_receivable_amount.to_f - previously_adjusted_amount_value), 0].max
      self.cn_previously_adjusted_amount = previously_adjusted_amount_value
      self.cn_net_adjustable_amount = net_adjustable_amount_value
      self.adjustments.update_all(cn_net_adjustable_amount: net_adjustable_amount_value)
    end
  end

  def update_status
    if precision_value(net_adjustable_amount.value) == 0
      self.status_id = CreditNoteStatus.id_for(:adjusted)
    elsif precision_value(net_adjustable_amount.value) < precision_value(net_receivable_amount.value)
      self.status_id = CreditNoteStatus.id_for(:partially_adjusted)
    elsif precision_value(net_adjustable_amount.value) == precision_value(net_receivable_amount.value)
      self.status_id = CreditNoteStatus.id_for(:unadjusted)
    end
    save(validation: false)
  end

  def set_currency_for_amount
    amount_attr = [:gross_receivable_amount, :tax_amount, :discount_amount, :net_receivable_amount, :tds_amount, :freight_amount, :previously_adjusted_amount, :net_adjustable_amount]
    amount_attr.each do |amount_attribute|
      amount_attr_id = self.send("#{amount_attribute}_id")
      if amount_attr_id.present?
        Amount.find_by(id: amount_attr_id).update(currency_id: get_base_currency.id)
      end
    end
    self.skip_callback = true
    self.save
  end
end
