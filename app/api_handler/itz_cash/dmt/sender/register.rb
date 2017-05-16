class ItzCash::Dmt::Sender::Register < ItzCash::Dmt::Base
  attr_accessor :username

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
    end
  end

  def request_type
    200
  end

  def query_xml_path
    "#{Rails.root}/app/api_handler/itz_cash/dmt/sender/register.xml.erb"
  end

  def query_xml_params
    {
        username: Constants::ItzCash::DMT_USERNAME,
        icw_code: Constants::ItzCash::ICW_CODE,
        first_name: user.first_name,
        middle_name: '',
        last_name: user.last_name,
        mobile_number: user.mobile_number,
        address: "#{user.address_1}, #{user.address_2}",
        state_id: user.state_id,
        city_id: '12901',
        pin_code: user.pin_code
    }
  end

  def success
    create_user_dmt_sender
    params[:parsed_response] = self.parsed_response
    ItzCash::Dmt::Sender::Register::SuccessPresenter.new(user, params, messages)
  end

  class ItzCash::Dmt::Sender::Register::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :parsed_response, :registration_id

    def init
      self.parsed_response = params[:parsed_response]
      self.registration_id = parsed_response[:SenderRegResponse][:registrationId]
    end

  end

  protected
  def create_user_dmt_sender
    param = {
        mobile_number: user.mobile_number,
        registration_id: parsed_response[:SenderRegResponse][:registrationId],
        status_id: ItzCashDmtSenderStatus.id_for(:active),
        otp_verified: false
    }
    if user.itz_cash_dmt_sender.present?
      user.itz_cash_dmt_sender.update param
    else
      user.build_itz_cash_dmt_sender(param).save
    end
  end

end