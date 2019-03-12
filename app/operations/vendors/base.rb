class Vendors::Base < BaseOperation
  attr_accessor :vendor, :workflow_output

  def init
    id = params[:vendor_id] || params[:yes_bank_vendor] || params[:id] 
    self.vendor = Vendors::Show.(user, params).vendors.with_id(id).first rescue nil
  end

  def validate
    unless self.vendor.present?
      add_message :error, "Vendor not found"
    end
  end
end