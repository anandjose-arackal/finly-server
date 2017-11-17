class Personalizer::Adapters::Company49::Vendors49::Create49::Validate < Personalizer::Adapters::Base

  attr_accessor :vendor_params

  def init
    self.vendor_params = self.op_instance.vendor_parameters
  end

  def validate
    if self.vendor_params[:vendor_attachment_attributes].blank?
      add_message :error, "All vendors must be created with a compulsory image of a cancelled cheque leaf"
      return
    end
  end
end