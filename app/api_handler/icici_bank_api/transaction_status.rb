class IciciBankApi::TransactionStatus < IciciBankApi::Base

  attr_accessor :icici_bank_transaction, :api_response_success,
                :transaction_status_response

  class IciciBankApi::TransactionStatus::TransactionStatusPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :transaction_status_response

    def init
      self.transaction_status_response = params[:transaction_status_response]
    end

  end

  def init
    self.icici_bank_transaction = params[:icici_bank_transaction]
  end

  def icici_bank_action
    'icici_bank_transaction_status'
  end

  def raw_api_params
    {
        AGGRID: self.company_details["AGGR_ID"],
        CORPID: self.company_details["CORP_ID"],
        USERID: self.company_details["USER_ID"],
        URN: self.company.icici_bank_config.urn,
        UNIQUEID: self.icici_bank_transaction.unique_request_number
    }
  end

  def post_params
    encrypt_params(
        raw_api_params
    )
  end

  def post_process
    case self.response.status
      when 404

      when 500

      when 200
        self.api_response_success = true
        self.transaction_status_response = self.parsed_response["STATUS"]
        case self.transaction_status_response
          when "SUCCESS"
            self.icici_bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:completed))
          when "PROCESSING"
            self.icici_bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:completed))
          when "SUSPECT"
            self.icici_bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:suspect))
          when "PENDING"
            self.icici_bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:pending))
          when "FAILURE"
            self.icici_bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:failure))
          when "CANCELLED"
            self.icici_bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:cancelled))
          else

        end
      else
        # handle it gracefully
    end
  end

  def success?
    self.transaction_status_response.present?
  end

  def failure?
    self.transaction_status_response.blank?
  end

  def success
    params[:transaction_status_response] = self.transaction_status_response
    IciciBankApi::TransactionStatus::TransactionStatusPresenter.new(user, params, messages)
  end

end