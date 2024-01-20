class Vendors::BulkRejectProcessor < BackgroundOperation
  sidekiq_options queue: :payments_critical_queue

  attr_accessor :vendor_ids, :result

  def init
    self.vendor_ids = params[:vendor_ids]
    self.result = {
        success: [],
        error: []
    }
  end

  def validate
    if self.vendor_ids.blank?
      return
    end
  end

  def process
    vendor_ids.each do |id|
      data_success = {}
      data_error = {}
      op = Vendors::Reject.(user, {vendor_id: id}) # Disable mailer
      vendor = YesBankVendor.find_by id: id
      unless op.success?
        data_error[:messages] = op.messages[:error]
        data_error[:vendor_id] = vendor&.vendor_id
        data_error[:vendor_type] = vendor&.vendor_type&.name
        self.result[:error].push(data_error)
      else
        data_success[:vendor_id] = vendor&.vendor_id
        data_success[:vendor_type] = vendor&.vendor_type&.name
        self.result[:success].push(data_success)
      end
    end
  end

  def post_process
    # to be done later
    # op = Event::EVendor::BulkReject.(user, result: result)
  end
end
