class ItzCash::Dmt::Transfer::Create < ItzCash::Dmt::Base

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:beneficiary_id].blank?
      add_message :error, 'Beneficiary not found'
      return
    end
    if params[:amount].blank?
      add_message :error, 'Amount not found'
      return
    end
    if params[:amount].to_d <= 0
      add_message :error, 'Amount has to be greater than 0'
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
        payment_mode: Constants::ItzCash::DMT_PAYMENT_MODE,
        remit_type: 'IMPS'
    }
  end

  def success

  end

end