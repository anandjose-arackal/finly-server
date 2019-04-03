class Vendors::BulkTakeControl < Vendors::Base
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
  end

  def process
    Vendors::BulkApproveProcessor.call_async(user.id, {vendor_ids: vendors.pluck(:id)})
  end

  def post_process
    add_message :success, "Bulk approving multiple vendors (#{self.vendors.length})."
  end
end
