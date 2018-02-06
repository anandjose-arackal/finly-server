class Personalizer::Adapters::Company49::Vendors49::Update49::Validate < Personalizer::Adapters::Base

  attr_accessor :vendor_params

  def init
    self.vendor_params = self.op_instance.vendor_parameters
  end

  def validate
    # if they try to remove the attachment, ensure they cannot
    if self.vendor_params[:vendor_attachments_attributes]&.first&.dig(:remove_file) == '1' && self.vendor_params[:vendor_attachments_attributes]&.first&.dig(:attached_file).blank?
      add_message :error, "All vendors must have a compulsory attachment"
    end
    if self.vendor_params[:gst].blank?
      add_message :error, 'GST cannot be blank. If GSTIN is not present, please fill in NA'
    else
      gst = vendor_params[:gst]
      unless gst.match(/^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$/) or ['na', 'n/a'].include?(gst&.downcase)
        add_message :error, 'Invalid GST format'
      end
    end
    if self.vendor_params[:pan].blank?
      add_message :error, 'PAN cannot be blank. If PAN is not present, please fill in NA'
    else
      pan = vendor_params[:pan]
      unless pan.match(/(^([a-zA-Z]{5})([0-9]{4})([a-zA-Z]{1})$)/) or ['na', 'n/a'].include?(pan&.downcase)
        add_message :error, 'Invalid PAN format'
      end
    end
  end
end