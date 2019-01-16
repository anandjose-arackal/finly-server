# == Schema Information
#
# Table name: purchase_orders
#
#  id                           :integer          not null, primary key
#  company_id                   :integer
#  procurement_id               :integer
#  location_id                  :integer
#  delivery_location_id         :integer
#  vendor_id                    :integer
#  payment_term_id              :integer
#  procurement_term_id          :integer
#  purchase_order_status_id     :integer
#  indent_number                :string(255)
#  indent_date                  :date
#  po_number                    :string(255)
#  override_po_number           :boolean
#  prefix                       :string(255)
#  sequence_start               :string(255)
#  delivery_date                :date
#  gst_type_id                  :integer
#  inclusive_of_taxes           :boolean
#  roundoff_total_enabled       :boolean
#  roundoff_amount              :decimal(10, 5)
#  transaction_amount_id        :integer
#  total_before_tax_id          :integer
#  tax_amount_id                :integer
#  total_after_tax_id           :integer
#  discount_amount_id           :integer
#  balance_amount_id            :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  user_id                      :integer
#  procurement_term_text        :text(65535)
#  controlling_user_id          :integer
#  controlling_user_role_id     :integer
#  controlling_for_user_id      :integer
#  controlling_for_user_role_id :integer
#  policy_id                    :integer
#  controlling_level_id         :integer
#  department_id                :integer
#  is_deleted                   :boolean          default(FALSE), not null
#  cost_center_id               :integer
#  sub_department_id            :integer
#  billing_address              :text(65535)
#  shipping_address             :text(65535)
#  is_template                  :boolean          default(FALSE)
#  template_name                :string(255)
#  resource_template_id         :integer
#

class PurchaseOrder < ActiveRecord::Base
  include SoftDeletable, Templatable, Transitionable
  belongs_to :company
  belongs_to :user
  belongs_to :procurement
  belongs_to :location, class_name: 'BranchLocation'
  belongs_to :delivery_location, class_name: 'BranchLocation'
  belongs_to :vendor, class_name: 'YesBankVendor'
  belongs_to :payment_term
  belongs_to :procurement_term
  belongs_to :status, class_name: 'PurchaseOrderStatus', foreign_key: :purchase_order_status_id
  belongs_to :department
  belongs_to :sub_department, class_name: "Department", foreign_key: :sub_department_id
  belongs_to :cost_center
  belongs_to :gst_type

  belongs_to :controlling_user, class_name: 'User'
  belongs_to :controlling_for_user, class_name: 'User'
  belongs_to :controlling_user_role, class_name: 'UserRole'
  belongs_to :controlling_for_user_role, class_name: 'UserRole'

  belongs_to :total_before_tax, class_name: "Amount"
  belongs_to :tax_amount, class_name: "Amount"
  belongs_to :total_after_tax, class_name: "Amount"
  belongs_to :discount_amount, class_name: "Amount", autosave: true
  belongs_to :balance_amount, class_name: "Amount", autosave: true
  belongs_to :policy
  belongs_to :level, class_name: 'ReviewalLevel', foreign_key: :controlling_level_id


  has_many :document_level_reviewer_mappings, as: :document_reviewer_mappable

  has_many :attachments, class_name: "ProcurementAttachment", as: :procurement_document

  has_many :items, class_name: "PurchaseOrderItem", dependent: :destroy
  has_many :extra_charges, class_name: "ProcurementCharge", as: "Chargable"
  has_many :comments, class_name: 'ProcurementComment', as: :parent_commentable
  # has_many :custom_fields, as: :parent
  has_many :custom_fields, as: :parent, dependent: :destroy
  has_many :advance_payments, class_name: "Payment"

  has_many :trails, as: :parent

  delegate :open?, :retracted?, :rejected?, :processing?, :approved?, :auto_approved?, :sent_to_vendor?, :closed?, :voided?, to: :status

  accepts_nested_attributes_for :items, allow_destroy: true
  accepts_nested_attributes_for :total_before_tax, :tax_amount, :total_after_tax, :discount_amount, :balance_amount
  accepts_nested_attributes_for :custom_fields


  validates :purchase_order_status_id, presence: true
  # validates :policy_id, presence: true
  # validates :items, presence: true
  scope :document_number_generated_in_finly, -> {where override_po_number: [false, nil]}

  scope :with_id, -> (id) {where id: id}
  scope :with_user_id, -> (user_ids) {where user_id: user_ids}
  scope :with_status_ids, -> (status_ids) {where purchase_order_status_id: status_ids}
  scope :with_controlling_level_ids, -> (level_ids) {where controlling_level_id: level_ids}
  scope :with_controlling_user_id, -> (id) {where controlling_user_id: id}
  scope :with_procurement_id, ->(procurement_id) {where procurement_id: procurement_id}
  scope :filter_po_number, -> (po_number) {where('purchase_orders.po_number LIKE ?', "%#{po_number}%")}
  scope :with_vendor_ids, -> (ids) {where vendor_id: ids}
  scope :with_po_number, -> (po_number) {where po_number: po_number}
  scope :with_budgetable_department_ids, -> (department_ids) {
    if department_ids.present?
      ids = where(department_id: department_ids).pluck(:id)
      ids += where(sub_department_id: department_ids).pluck(:id)
      where(id: ids)
    end
  }
  scope :with_budgetable_location_ids, -> (location_ids) {
    if location_ids.present?
      where location_id: location_ids
    end
  }
  scope :with_budgetable_user_ids, -> (user_ids) {
    if user_ids.present?
      where created_by_user_id: user_ids
    end
  }
  scope :with_budgetable_vendor_ids, -> (vendor_ids) {
    if vendor_ids.present?
      where vendor_id: vendor_ids
    end
  }
  # Used for generating document number
  scope :valid, -> {
    status_ids = [
        PurchaseOrderStatus.id_for(:processing),
        PurchaseOrderStatus.id_for(:rejected),
        PurchaseOrderStatus.id_for(:retracted),
        PurchaseOrderStatus.id_for(:approved),
        PurchaseOrderStatus.id_for(:auto_approved),
        PurchaseOrderStatus.id_for(:sent_to_vendor),
        PurchaseOrderStatus.id_for(:closed)
    ]
    where purchase_order_status_id: PurchaseOrderStatus.id_for(status_ids)
    # ids = pluck(:id)
    # ids = PurchaseOrderItem.where(purchase_order_id: ids).pluck(:purchase_order_id)
    # where(id: ids)
  }

  scope :filter_sub_department_id, -> (ids) {
    where sub_department_id: ids
  }

  scope :filter_department_id, -> (ids) {
    where department_id: ids
  }

  scope :filter_vendor_id, -> (ids){
    where vendor_id: ids
  }

  scope :filter_user_id, -> (ids){
    where user_id: ids
  }

  scope :filter_payment_term_id, -> (ids) {
    where payment_term_id: ids
  }

  before_save :calculate_line_items
  after_save :budget_trail_entry
  after_destroy :budget_trail_destroy


  template_config do
    include_association [:policy, :location, :delivery_location, :vendor,
                          :payment_term, :procurement_term, :department,
                          :sub_department, :cost_center]
    clone [:extra_charges, :items, :document_level_reviewer_mappings, :total_before_tax,
           :tax_amount, :total_after_tax, :discount_amount, :custom_fields]

    customize(lambda { |po,new_po|
      new_po.trails.destroy_all
      new_po.comments.destroy_all
      new_po.attachments.destroy_all
    })

    nullify :procurement_id
    nullify :po_number
    nullify :is_template
    nullify :template_name
    nullify :controlling_level_id
    nullify :controlling_user_id
    nullify :controlling_for_user_id
    nullify :controlling_user_role_id
    nullify :controlling_for_user_role_id
    nullify :balance_amount_id
    set :purchase_order_status_id => PurchaseOrderStatus.id_for(:open)
    nullify :user_id
  end

  template_merge :procurement_id, :user_id, :vendor_id

  def all_items_shipped?
    shipped = true
    self.items.each do |item|
      unless item.quantity == item.delivered
        shipped = false
        break
      end
    end
    shipped
  end

  def procurement_index_details
    {
        id: id,
        document_number: self.po_number,
        amount: self.balance_amount&.value,
        document_status: self.status&.name,
        document_owner: self.user&.name,
        document_type: self.class.name
    }
  end

  def can_unapprove?(user=nil)
    return false if user.blank?

    last_approve_trail = self.trails.natural_order.only_approve.last
    last_retract_trail = self.trails.natural_order.only_retract.last
    if last_approve_trail.action_user.id == user.id
      if last_retract_trail.present? && last_retract_trail.created_at > last_approve_trail.created_at
        return false
      end
      return true
    else
      return false
    end
  end

  private

  def calculate_line_items
    total_before_tax_amount = 0
    total_after_tax_amount = 0
    tax_amount = 0
    discount_amount = 0
    balance_amount = 0
    total_amount = 0
    persisted = false

    self.items.each do |item|
      if item.persisted?
        persisted = true
      end
      if item.is_a?(PurchaseOrderItem)
        item_quantity = (item.quantity || 0).to_f
        item_rate = (item.rate || 0).to_f
        item_tax = (item.tax || 0).to_f
        item_discount = (item.discount || 0).to_f

        # Exclusive of tax
        item_amount = (item_quantity * item_rate)
        item_discount_amount = item_amount * item_discount / 100
        item_taxable_amount = item_amount - item_discount_amount
        item_tax_amount = item_taxable_amount * item_tax / 100
        item_total_amount = item_taxable_amount + item_tax_amount

        # Add to parent's amounts
        tax_amount += item_tax_amount
        discount_amount += item_discount_amount
        total_before_tax_amount += item_taxable_amount
        total_after_tax_amount += item_total_amount
        total_amount += item_total_amount

        # if persisted
        if item.tax_amount.present?
          item.tax_amount.value = item_tax_amount
        else
          item.tax_amount = Amount.new(value: item_tax_amount, currency_id: 1)
        end

        if item.discount_amount.present?
          item.discount_amount.value = item_discount_amount
        else
          item.discount_amount = Amount.new(value: item_discount_amount, currency_id: 1)
        end

        if item.total_amount.present?
          item.total_amount.value = item_total_amount
        else
          item.total_amount = Amount.new(value: item_total_amount, currency_id: 1)
        end


        # end
      end
    end

    if self.total_before_tax.present?
      self.total_before_tax.value = total_before_tax_amount
    else
      self.total_before_tax = Amount.new(value: total_before_tax_amount, currency_id: 1)
    end

    if self.total_after_tax.present?
      self.total_after_tax.value = total_after_tax_amount
    else
      self.total_after_tax = Amount.new(value: total_after_tax_amount, currency_id: 1)
    end
    # if self.total_amount.present?
    #   self.total_amount.value = total_amount
    # else
    #   self.total_amount = Amount.new(value: total_amount, currency_id: 1)
    # end
    if self.discount_amount.present?
      self.discount_amount.value = discount_amount
    else
      self.build_discount_amount(value: discount_amount, currency_id: 1)
    end

    if self.tax_amount.present?
      self.tax_amount.value = tax_amount
    else
      self.build_tax_amount(value: tax_amount, currency_id: 1)
    end

    if self.balance_amount.present?
      self.balance_amount.value = total_amount
    else
      self.build_balance_amount(value: total_amount, currency_id: 1)
    end

    # self.save
  end

  def budget_trail_entry
    if self.voided? || self.rejected? || self.retracted? || self.open?
      # this will delete the trails of all the items within this particular purchase order
      self.items.each do |item|
        BudgetsCalculator::Calculate::PurchaseOrderItemsBudgetsProcessor.new.destroy_trail(item)
      end
    else
      self.items.each do |item|
        BudgetsCalculator::Calculate::PurchaseOrderItemsBudgetsProcessor.new.save_trail(item)
      end
    end
  end

  def budget_trail_destroy
    self.items.each do |item|
      BudgetsCalculator::Calculate::PurchaseOrderItemsBudgetsProcessor.new.destroy_trail(item)
    end
  end

  def self.document_owner_attribute
    'user_id'
  end

  def self.document_status_attribute
    'purchase_order_status_id'
  end

  def self.finance_associated_status_ids
    PurchaseOrderStatus.ids_for(:approved, :auto_approved, :sent_to_vendor, :closed, :voided)
  end
end
