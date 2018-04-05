class TdsSlabs::Create < TdsSlabs::Base

  attr_accessor :tds_slab, :tds_slab_parameters

  def init
    self.tds_slab_parameters = tds_slab_params
  end

  def pre_process

  end

  def process
    self.tds_slab = user.company.tds_slabs.build(self.tds_slab_parameters)
    unless self.tds_slab.save
      add_message :error, self.tds_slab.errors.full_messages
    end
  end

  def post_process
    add_message :success, "TDS Slab created!"
  end
end