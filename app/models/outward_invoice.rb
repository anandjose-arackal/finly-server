# == Schema Information
#
# Table name: outward_invoices
#
#  id                      :integer          not null, primary key
#  customer_id             :integer
#  date                    :date
#  due_date                :date
#  amount_id               :integer
#  discount_amount_id      :integer
#  tax_amount_id           :integer
#  paid_amount_id          :integer
#  advance                 :decimal(10, 5)
#  freight_amount_id       :integer
#  balance_due_id          :integer
#  roundoff_amount         :decimal(10, 5)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  policy_id               :integer
#  invoice_status_id       :integer
#  company_id              :integer
#  invoice_number          :string(255)
#  gst_type_id             :integer
#  inclusive_of_taxes      :boolean
#  advance_amount_id       :integer
#  net_amount_id           :integer
#  virtual_account_id      :integer
#  billing_address         :text(65535)
#  shipping_address        :text(65535)
#  email                   :string(255)
#  mobile_number           :string(255)
#  override_invoice_number :boolean
#  is_deleted              :boolean
#  sequence_start          :string(255)
#  prefix                  :string(255)
#  total_payable_id        :integer
#  roundoff_total_enabled  :boolean
#  memo                    :string(255)
#

class OutwardInvoice < ActiveRecord::Base

  include SoftDeletable

  include MathUtil

  belongs_to :customer
  belongs_to :company
  belongs_to :amount
  belongs_to :policy
  belongs_to :discount_amount, class_name: "Amount"
  belongs_to :tax_amount, class_name: "Amount"
  belongs_to :original_amount, class_name: "Amount"
  belongs_to :paid_amount, class_name: "Amount"
  belongs_to :balance_due, class_name: "Amount"
  belongs_to :freight_amount, class_name: "Amount"
  belongs_to :advance_amount, class_name: "Amount"
  belongs_to :net_amount, class_name: "Amount"
  belongs_to :gross_amount, class_name: "Amount"
  belongs_to :total_payable, class_name: "Amount"
  belongs_to :invoice_status, class_name: "OutwardInvoiceStatus"
  belongs_to :payment_term

  # has_one :virtual_bank_account, as: :parent
  belongs_to :virtual_account, class_name: "VirtualBankAccount"

  has_many :invoice_items, class_name: "InvoiceLineItem", as: :parent
  has_many :payments, as: :parent

  delegate :partially_paid?, :closed?, :incomplete?, :saved?, :cancelled?, to: :invoice_status

  accepts_nested_attributes_for :customer
  accepts_nested_attributes_for :amount
  accepts_nested_attributes_for :gross_amount
  accepts_nested_attributes_for :net_amount
  accepts_nested_attributes_for :discount_amount
  accepts_nested_attributes_for :tax_amount
  accepts_nested_attributes_for :original_amount
  accepts_nested_attributes_for :freight_amount
  accepts_nested_attributes_for :advance_amount
  accepts_nested_attributes_for :balance_due
  accepts_nested_attributes_for :paid_amount
  accepts_nested_attributes_for :total_payable
  accepts_nested_attributes_for :invoice_items, allow_destroy: true

  validates :invoice_status, presence: true

  validates :invoice_items, presence: true, if: :valid_invoice?
  validates :invoice_number, presence: true, if: :valid_invoice?
  validates :customer_id, presence: true, if: :valid_invoice?
  validates :billing_address, presence: true, if: :valid_invoice?
  validates :shipping_address, presence: true, if: :valid_invoice?
  validates :company_id, presence: true, if: :valid_invoice?
  validates :balance_due, presence: true, if: :valid_invoice?
  validates :discount_amount, presence: true, if: :valid_invoice?
  validates :tax_amount, presence: true, if: :valid_invoice?
  validates :net_amount, presence: true, if: :valid_invoice?
  validate :gst_type_selection, if: :valid_invoice?

  scope :unpaid, -> { where(invoice_status_id: OutwardInvoiceStatus.ids_for([:unpaid, :saved, :partially_paid, :sent_to_customer]))}
  scope :paid, -> { where invoice_status_id: OutwardInvoiceStatus.id_for(:closed) }
  scope :payments_receivable, -> { where(invoice_status_id: OutwardInvoiceStatus.ids_for([:saved, :partially_paid])) }

  scope :valid, -> { where invoice_status_id: OutwardInvoiceStatus.ids_for([:saved, :partially_paid, :closed, :cancelled]) }
  scope :invoice_number_generated_in_finly, -> { where override_invoice_number: [false, nil] }
  scope :without_id, -> (id){ where.not id: id}

  before_save do
    if self.invoice_number.blank? && valid_invoice?
      generate_invoice_number
    end
  end

  default_scope { unscope(:where) }

  def invoice_status_identifier
    self.invoice_status&.name
  end

  def editable?
    !(self.invoice_status_id == OutwardInvoiceStatus.id_for(:cancelled))
  end

  def line_items_total
    self.invoice_items.joins(:amount).sum(:value)
  end

  def line_items_net_total
    self.invoice_items.joins(:net_amount).sum(:value)
  end

  private

  # as in, an invoice that has been saved and is payable by
  # the customer
  def valid_invoice?
    !(self.invoice_status_id == OutwardInvoiceStatus.id_for(:incomplete) || self.invoice_status_id == OutwardInvoiceStatus.id_for(:cancelled))
  end

  def generate_invoice_number
    company = self.company
    if company.blank?
      return nil
    else
      number = MathUtil.generate_random_number(10)
      while OutwardInvoice.find_by(invoice_number: number)
        number = MathUtil.generate_random_number(10)
      end
    end
    number
  end

  def gst_type_selection
    if self.tax_amount&.value > 0
      if self.gst_type_id.blank?
        errors.add(:gst_type, "cannot be blank")
      end
    end
  end

end
