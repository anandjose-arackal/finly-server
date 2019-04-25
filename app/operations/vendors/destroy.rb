class Vendors::Destroy < Vendors::Base

  def init
    # id = params[:id] || params[:yes_bank_vendor_id] || params[:vendor_id]
    self.vendor = Vendors::Show.(user, params).vendor rescue nil
  end

  def validate
    if self.vendor.blank?
      add_message :error, "Vendor not found"
    end

    unless user.is_vendor_manager? || user.vendor_payment_admin?
      add_message :error, "You cannot perform this action"
    end
  end

  def process
    unless self.vendor.destroy
      add_message :error, self.vendor.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Vendor successfully deleted"
  end
end