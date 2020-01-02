# == Schema Information
#
# Table name: security_deposits
#
#  id                              :bigint           not null, primary key
#  vendor_id                       :integer
#  vendor_location_id              :integer
#  cost_center_id                  :integer
#  department_id                   :integer
#  location_id                     :integer
#  note                            :text(65535)
#  description                     :text(65535)
#  payable_amount_id               :integer
#  original_amount_id              :integer
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  payment_agreement_id            :integer
#  bank_account_id                 :integer
#  company_id                      :integer
#  creator_id                      :integer
#  payment_agreement_upcoming_date :date
#  status_id                       :integer
#

# Security deposit is required to create rental invoice in payment agreements

class SecurityDeposit < ApplicationRecord

  belongs_to :vendor,  class_name: 'YesBankVendor'
  belongs_to :cost_center, optional: true
  belongs_to :department, optional: true
  belongs_to :location, optional: true, class_name: "BranchLocation"
  belongs_to :vendor_location, optional: true, class_name: "GstinLocation"
  belongs_to :payable_amount, optional: true, class_name: "Amount"
  belongs_to :original_amount, optional: true, class_name: "Amount"
  belongs_to :bank_account, optional: true
  belongs_to :company, optional: true
  belongs_to :creator, optional: true, class_name: "User"
  belongs_to :payment_agreement, optional: true
  belongs_to :status, optional: true, class_name: 'SecurityDepositStatus'

  has_many :payments, as: :parent
  has_many :trails, as: :parent

  validates :vendor, :vendor_location, :bank_account, :cost_center, :department, :location, :original_amount, presence: true

  after_create :update_creator_id, :update_company_id, :update_status

  accepts_nested_attributes_for :payable_amount, :original_amount




  def as_json(options={})
    # {
    #   id: self.id, 
    #   vendor_id: self.vendor_id,
    #   vendor_name: self&.vendor&.name,
    #   cost_center_id: self.cost_center_id,
    #   vendor_location_id: self.vendor_location_id,
    #   department_id: self.department_id,
    #   location_id: self.location_id,
    #   description: self.description,
    #   note: self.note,
    #   original_amount_attributes: {id: self.original_amount_id, value: self.original_amount&.value, currency_id: self.original_amount&.currency_id },
    #   payable_amount_attributes: {id: self.payable_amount_id, value: self.payable_amount&.value, currency_id: self.payable_amount&.currency_id}
    # }

    {
      id: self.id,
      vendor_attributes: {id: self.vendor_id, name: self.vendor&.name, business_name: self.vendor&.business_name, trade_name: self.vendor&.trade_name},
      bank_account_attributes: {id: self.bank_account_id, name: self.bank_account&.name, account_number: self.bank_account&.account_number, ifsc: self.bank_account&.ifsc },
      vendor_location_attributes: { id: self.vendor_location_id, location: self.vendor_location&.location, gstin: self.vendor_location&.gstin, address: self.vendor_location&.address },
      department_attributes: { id: self.department_id, name: self.department&.name },
      location_attributes: { id: self.location_id, name: self.location&.name },
      cost_center_attributes: { id: self.cost_center_id, name: self.cost_center&.name }, 
      note: self.note,
      original_amount_attributes: {id: self.original_amount_id, value: self.original_amount&.value, currency_id: self.original_amount&.currency_id},
      vendor_locations: fetch_vendor_locations.as_json,
      bank_accounts: fetch_vendor_bank_accounts.as_json,
      net_amount_attributes: {id: self.original_amount_id, value: self.original_amount&.value, currency_id: self.original_amount&.currency_id},
      balance_due_attributes: {id: self.original_amount_id, value: self.original_amount&.value, currency_id: self.original_amount&.currency_id},
      vendor_id: self.vendor_id,
      payment_agreement_id: self.payment_agreement_id,
      vendor_name: self.vendor&.name,
      vendor_code: self.vendor&.vendor_id,
      creation_date: self.created_at.to_date,
      agreement_type: 'security_deposit',
      status_attributes: {id: self.status&.id, name: self.status&.name, display_name: self.status&.name&.titleize, payment_agreement_status: self.payment_agreement&.status&.name},
      net_payable_amount: self.original_amount&.value,
      tax_amount: (self.tax_amount.value rescue 0),
      tds_amount: (self.tds_amount.value rescue 0),
      tax: (self.tax rescue 0),
      tds: (self.tds_slab.tds rescue 0),
      bank_payment_request_id: (self.payments.first.payment_order.bank_payment_request.id rescue nil),
      already_exists: true
    }
  end

  def document_owner_attribute
    'creator_id'
  end

  private
  
  def fetch_vendor_locations
    self.vendor&.gstin_locations&.as_json
  end

  def fetch_vendor_bank_accounts
    self.vendor&.bank_accounts&.non_deleted&.as_json
  end

  def update_creator_id
    if self.creator_id.blank?
      self.update(creator: RequestStore.store[:current_user])
    end
  end

  def update_company_id
    if self.company_id.blank?
      self.update(company_id: self.payment_agreement.company_id)
    end
  end

  def update_status
    self.update(status_id: SecurityDepositStatus.id_for(:unpaid))
  end

end
