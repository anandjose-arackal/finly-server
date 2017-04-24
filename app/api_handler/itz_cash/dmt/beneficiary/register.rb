class ItzCash::Dmt::Beneficiary::Register < ItzCash::Dmt::Base

  # todo - Untested, incomplete as we are currently waiting for ItzCash to get back to see if this is even required
  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
    end
  end

  def request_type
    300
  end

  def query_xml_path
    "#{Rails.root}/app/api_handler/itz_cash/dmt/beneficiary/register.xml.erb"
  end

  def query_xml_params
    {
        username: user.itz_cash_dmt_sender.username,
        icw_code: Constants::ItzCash::ICW_CODE,
        sender_mobile_number: user.mobile_number
    }
  end

end