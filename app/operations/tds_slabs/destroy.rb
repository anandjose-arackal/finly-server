class TdsSlabs::Destroy < TdsSlabs::Base

  attr_accessor :tds_slab

  def init
    id = params[:id] || params[:tds_slab_id]
    self.tds_slab = user.company.tds_slabs.find_by(id: id)
  end

  def authorized_user_types
    [:company_admin, :vendor_payments_admin]
  end

  def validate
    if self.tds_slab.blank?
      add_message :error, "TDS slabs not found"
      return
    end
  end

  def process
    unless self.tds_slab.destroy
      add_message :error, self.tds_slab.errors.full_messages
    end
  end

  def post_process
    add_message :success, "TDS slabs destroyed!"
  end
end