class TdsSlabs::Update < TdsSlabs::Base

  attr_accessor :tds_slab

  def init
    id = params[:id] || params[:tds_slab_id]
    self.tds_slab = user.company.tds_slabs.find_by(id: id)
    self.tds_slab_parameters = tds_slab_params
  end

  def authorized_user_types
    [:company_admin, :vendor_payments_admin]
  end

  def validate
    if self.tds_slab.blank?
      add_message :error, "TDS Slab not found"
      return
    end
  end

  def process
    unless self.tds_slab.update(self.tds_slab_parameters)
      add_message :error, self.tds_slab.errors.full_messages
    end
  end

  def post_process
    add_message :success, "TDS Slab updated!"
  end
end