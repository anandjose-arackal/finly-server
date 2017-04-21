class ItzCash::Dmt::Sender::Registration < ItzCash::Dmt::Base

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
    end
  end

  def request_type
    200
  end

  def query_xml_path
    "#{Rails.root}/app/api_handler/itz_cash/dmt/sender/registration.xml.erb"
  end

  def query_xml_params
    {
        user_name: "#{}",
        icw_code: 'D000000010',
        first_name: user.first_name,
        middle_name: '',
        last_name: user.last_name,
        mobile_number: user.mobile_number,
        address: "#{user.address_1}, #{user.address_2}",
        state_id: user.state_id,
        city_id: '12901',
        pin_code: user.pin_code,
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