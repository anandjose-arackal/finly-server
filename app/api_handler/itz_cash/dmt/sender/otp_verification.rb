class ItzCash::Dmt::Sender::Registration < ItzCash::Dmt::Base

  def request_type
    201
  end

  def query_xml_path
    "#{Rails.root}/app/api_handler/itz_cash/dmt/sender/otp_verification.xml.erb"
  end

  def query_xml_params
    {
        user_name: 'ITZIC03000',
        icw_code: 'D000000010',
        first_name: 'Tom',
        middle_name: 'David',
        last_name: 'Cruise',
        mobile_number: '9141516121',
        address: 'Mumbai',
        state_id: '21',
        city_id: '12901',
        pin_code: '414141',
        check_sum: nil
    }
  end

  # def success
  #   params[:parsed_response] = self.parsed_response
  #   ItzCash::Dmt::Sender::Registration::SuccessPresenter.new(user, params, messages)
  # end
  #
  # class ItzCash::Dmt::Sender::Registration::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
  #   # attr_accessor :
  # end

end