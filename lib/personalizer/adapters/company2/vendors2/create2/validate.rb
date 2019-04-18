class Personalizer::Adapters::Company2::Vendors2::Create2::Validate < Personalizer::Adapters::Base

  attr_accessor :vendor_params

  def init
    self.vendor_params = self.op_instance.vendor_parameters
  end

  def validate
    # if self.vendor_params[:gst].blank? && StringUtils.to_bool(self.vendor_params[:gst_registered])
    #   add_message :error, 'GST cannot be blank.'
    #   return
    # elsif vendor_params[:gst].present?
    #   gst = vendor_params[:gst]
    #   unless gst.match(/^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$/)
    #     add_message :error, 'Invalid GST format'
    #     return
    #   end
    # end
    # if self.vendor_params[:pan].blank?
    #   add_message :error, 'PAN cannot be blank.'
    # elsif vendor_params[:pan].present?
    #   pan = vendor_params[:pan]
    #   unless pan.match(/(^([a-zA-Z]{5})([0-9]{4})([a-zA-Z]{1})$)/)
    #     add_message :error, 'Invalid PAN format'
    #     return
    #   end
    # end

    # if self.vendor_params[:state_code_id].blank?
    #   add_message :error, "State cannot be blank"
    #   return
    # end

  end
end