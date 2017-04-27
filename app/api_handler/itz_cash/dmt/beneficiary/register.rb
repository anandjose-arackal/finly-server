class ItzCash::Dmt::Beneficiary::Register < ItzCash::Dmt::Base

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
        username: Constants::ItzCash::DMT_USERNAME,
        icw_code: Constants::ItzCash::ICW_CODE,
        sender_mobile_number: user.mobile_number
    }
  end

end