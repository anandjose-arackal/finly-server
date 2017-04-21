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

  def success
    create_user_dmt_sender
    params[:parsed_response] = self.parsed_response
    ItzCash::Dmt::Sender::Registration::SuccessPresenter.new(user, params, messages)
  end

  class ItzCash::Dmt::Sender::Registration::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :parsed_response, :registration_id

    def init
      self.parsed_response = params[:parsed_response]
      self.registration_id = parsed_response[:SenderRegResponse][:registrationId]
    end

  end

  protected
  def create_user_dmt_sender
    param = {username: self.username, mobile_number: user.mobile_number, registration_id: parsed_response[:SenderRegResponse][:registrationId]}
    if user.itz_cash_dmt_sender.present?
      user.itz_cash_dmt_sender.update param
    else
      user.build_itz_cash_dmt_sender(param).save
    end
  end


end