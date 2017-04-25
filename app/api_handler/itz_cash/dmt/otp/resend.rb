class ItzCash::Dmt::Otp::Resend < ItzCash::Dmt::Base

  TYPE = {
      sender_registration: 'S',
      beneficiary_registration: 'B'
  }

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if user.itz_cash_dmt_sender.blank?
      add_message :error, 'You have not enabled Bank Transfers'
      return
    end
    if params.blank? or params[:type].blank? or TYPE.key(params[:type]).blank?
      add_message :error, 'Error while resending OTP. Invalid Type'
      return
    end
  end

  def request_type
    601
  end

  def query_xml_path
    "#{Rails.root}/app/api_handler/itz_cash/dmt/otp/resend.xml.erb"
  end

  def query_xml_params
    {
        username: self.user.itz_cash_dmt_sender.username,
        icw_code: Constants::ItzCash::ICW_CODE,
        otp_type: params[:type],
        mobile_number: self.user.mobile_number,
        order_id: nil
    }
  end

end