class SecurityDeposit < ApplicationRecord

  belongs_to :vendor,  class_name: 'YesBankVendor'
  belongs_to :cost_center, optional: true
  belongs_to :department, optional: true
  belongs_to :location, optional: true, class_name: "BranchLocation"
  belongs_to :vendor_location, optional: true, class_name: "GstinLocation"
  belongs_to :payable_amount, optional: true, class_name: "Amount"
  belongs_to :original_amount, optional: true, class_name: "Amount"

  accepts_nested_attributes_for :payable_amount, :original_amount




  def as_json
    {
      id: self.id, 
      vendor_id: self.vendor_id,
      cost_center_id: self.cost_center_id,
      vendor_location_id: self.vendor_location_id,
      department_id: self.department_id,
      location_id: self.location_id,
      description: self.description,
      note: self.note
    }
  end


end
