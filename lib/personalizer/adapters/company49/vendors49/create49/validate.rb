class Personalizer::Adapters::Company49::Vendors49::Create49::Validate < Personalizer::Adapters::Base

  attr_accessor :vendor_params

  def init
    self.vendor_params = self.op_instance.vendor_parameters
  end

  def validate
    if self.vendor_params[:vendor_attachments_attributes]&.first&.dig(:attached_file).blank?
      add_message :error, "All vendors must have a compulsory attachment"
    end
  end
end