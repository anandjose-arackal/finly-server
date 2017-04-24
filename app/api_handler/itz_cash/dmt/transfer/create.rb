class ItzCash::Dmt::Transfer::Create < ItzCash::Dmt::Base

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def request_type
    401
  end

  def query_xml_path
    "#{Rails.root}/app/api_handler/itz_cash/dmt/transfer/create.xml.erb"
  end

  def query_xml_params
    {
        username: user.itz_cash_dmt_sender.username,
        icw_code: Constants::ItzCash::ICW_CODE,
        processing_bank_id: Constants::ItzCash::PROCESSING_BANK_ID,
        processing_bank_name: Constants::ItzCash::PROCESSING_BANK_NAME,
        sender_mobile_number: user.mobile_number,
        sender_name: "#{user.first_name} + #{user.last_name}",
        sender_id: user.itz_cash_dmt_sender.registration_id,
        beneficiary_id: params[:beneficiary_id],
        amount: params[:amount],
        payment_mode: 'easyPay',
        remit_type: 'IMPS'
    }
  end

  def success
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
  # todo move create outside
  def create_user_dmt_sender
    param = {username: self.username, mobile_number: user.mobile_number, registration_id: parsed_response[:SenderRegResponse][:registrationId]}
    if user.itz_cash_dmt_sender.present?
      user.itz_cash_dmt_sender.update param
    else
      user.build_itz_cash_dmt_sender(param).save
    end
  end

end