class ItzCash::Dmt::Beneficiary::Add < ItzCash::Dmt::Base

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if user.itz_cash_dmt_sender.blank?
      add_message :error, 'Registration not found'
      return
    end
    if params.blank?
      add_message :error, 'Beneficiary details cannot be blank'
      return
    end
    if params[:first_name].blank?
      add_message :error, 'First Name cannot be blank'
      return
    end
    if params[:last_name].blank?
      add_message :error, 'First Name cannot be blank'
      return
    end
    if params[:beneficiary_mobile_number].blank?
      add_message :error, 'Mobile Number cannot be blank'
      return
    end
    if params[:beneficiary_mobile_number].size != 10
      add_message :error, 'Invalid mobile number'
      return
    end
    if params[:ifsc_code].blank?
      add_message :error, 'IFSC Code cannot be blank'
      return
    end
    if params[:account_number].blank?
      add_message :error, 'Account Number cannot be blank'
      return
    end
    if params[:account_number_confirmation].blank?
      add_message :error, 'Account Number confirmation cannot be blank'
      return
    end
    if params[:account_number] != params[:account_number_confirmation]
      add_message :error, 'Account numbers do not match'
    end
  end

  def request_type
    302
  end

  def query_xml_path
    "#{Rails.root}/app/api_handler/itz_cash/dmt/beneficiary/add.xml.erb"
  end

  def query_xml_params
    {
        username: user.itz_cash_dmt_sender.username,
        icw_code: Constants::ItzCash::ICW_CODE,
        sender_mobile_number: user.mobile_number,
        sender_id: user.itz_cash_dmt_sender.registration_id,
        first_name: params[:first_name],
        middle_name: params[:middle_name],
        last_name: params[:last_name],
        beneficiary_mobile_number: params[:beneficiary_mobile_number],
        relation: Constants::ItzCash::BENEFICIARY_REGISTRATION_RELATION,
        ifsc_option: Constants::ItzCash::IFSC_OPTION,
        ifsc_code: params[:ifsc_code],
        account_number: params[:account_number],
        account_number_confirmation: params[:account_number_confirmation],
        processing_bank_id: Constants::ItzCash::PROCESSING_BANK_ID,
        beneficiary_check: 'N',
        easy_wallet_id: Constants::ItzCash::EASY_WALLET_ID,
        easy_wallet_type: Constants::ItzCash::EASY_WALLET_TYPE,
        account_password: user.itz_cash_dmt_sender.password
    }
  end

  def success
    create_user_dmt_beneficiary
    params[:parsed_response] = self.parsed_response
    ItzCash::Dmt::Beneficiary::Registration::SuccessPresenter.new(user, params, messages)
  end

  class ItzCash::Dmt::Beneficiary::Registration::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :parsed_response

    def init
      self.parsed_response = params[:parsed_response]
    end

  end

  protected
  def create_user_dmt_beneficiary
    param = {username: self.username, mobile_number: user.mobile_number, registration_id: parsed_response[:SenderRegResponse][:registrationId]}
    if user.itz_cash_dmt_sender.present?
      user.itz_cash_dmt_sender.update param
    else
      user.build_itz_cash_dmt_sender(param).save
    end
  end

end