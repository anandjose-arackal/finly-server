class Vendors::BulkReject < Vendors::Base
  attr_accessor :vendors

  def init
    vendor_ids = params[:ids] || params[:vendor_ids]

    unless vendor_ids.is_a?(Array)
      add_message :error, 'Invalid configuration'
      return
    end

    self.vendors = Vendors::Index.(user, params).vendors.with_id(vendor_ids)
  end

  def validate
    if self.vendors.empty?
      add_message :error, 'No vendors found'
    end

    accept_vendor = []
    self.vendors.each do |vendor|
      valid = (vendor.can_reject?) ? true : false

      if valid
        accept_vendor << vendor.id
      end
    end
 
    self.vendors = self.vendors.where(id: accept_vendor)

    if self.vendors.blank?
      add_message :error, "None of the vendors are in a state to be rejected"
      return
    end

  end

  def process
    Vendors::BulkRejectProcessor.call_async(user.id, {vendor_ids: vendors.pluck(:id)})
  end

  def post_process
    add_message :success, "Rejecting multiple vendors (#{self.vendors.length})."
  end
end
