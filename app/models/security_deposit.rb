class SecurityDeposit < ApplicationRecord

  belongs_to :vendor,  class_name: 'YesBankVendor'
  belongs_to :cost_center, optional: true
  belongs_to :department, optional: true
  belongs_to :location, optional: true, class_name: "BranchLocation"
  belongs_to :vendor_location, optional: true, class_name: "GstinLocation"
  belongs_to :payable_amount, optional: true, class_name: "Amount"
  belongs_to :original_amount, optional: true, class_name: "Amount"
  belongs_to :bank_account, optional: true

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
      vendor_attributes: {id: self.vendor_id, name: self.vendor&.name, business_name: self.vendor&.business_name},
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
      creation_date: self.creation_date.to_date,
      agreement_type: 'security_deposit'
    }
  end

  private
  
  def fetch_vendor_locations
    self.vendor&.gstin_locations&.as_json
  end

  def fetch_vendor_bank_accounts
    self.vendor&.bank_accounts&.non_deleted&.as_json
  end

end
