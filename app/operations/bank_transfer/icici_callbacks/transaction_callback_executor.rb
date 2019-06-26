class BankTransfer::IciciCallbacks::TransactionCallbackExecutor < BaseOperation

  attr_accessor :aggr_id, :corp_id, :user_id, :urn, :txn_status,
                :request_id, :unique_id, :utr_number, :request_params,
                :company

  class BankTransfer::IciciCallbacks::TransactionCallbackExecutor::TransactionCallbackPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :utr_number

    def init
      self.utr_number = params[:utr_number]
    end
  end

  def initialize(request_params)
    self.request_params = request_params
  end

  def pre_validate
    if self.request_params.blank?
      add_message :error, "Invalid parameters, try again later"
    end
  end

  def init
    self.urn = self.request_params["URN"]
    self.unique_id = self.request_params["UNIQUEID"]
    self.request_id = self.request_params["REQUESTID"]
    self.txn_status = self.request_params["TXNSTATUS"]
    self.utr_number = self.request_params["UTRNUMBER"]
    icici_config = IciciBankConfig.find_by(urn: self.urn)
    self.company = icici_config.company
    # first find the transaction that is particular callback is referring to
    self.icici_bank_transaction = self.company.icici_bank_transactions.find_by(unique_request_number: self.unique_id)

    # create an ICICI Callback Transaction record and save it.
    IciciTransactionCallback.create(
            AGGRNAME: request_params[:AGGRNAME],
            AGGRID: request_params[:AGGRID],
            URN: request_params[:URN],
            UNIQUEID: request_params[:UNIQUEID],
            REQUESTID: request_params[:REQUESTID],
            TXNSTATUS: request_params[:TXNSTATUS],
            UTRNUMBER: request_params[:UTRNUMBER],
            CORPID: request_params[:CORPID],
            USERID: request_params[:USERID]
    )
  end

  def validate
    if self.urn.blank?
      add_message :error, "URN not present"
      return
    end

    if self.unique_id.blank?
      add_message :error, "Unique ID not present"
      return
    end

    if self.request_id.blank?
      add_message :error, "Request ID not present"
      return
    end

    if self.txn_status.blank?
      add_message :error, "Txn status not present"
      return
    end

    if self.icici_bank_transaction.blank?
      add_message :error, "Transaction not found"
    end
  end

  def process

  end

  def success
    params[:utr_number] = self.utr_number
    BankTransfer::IciciCallbacks::TransactionCallbackExecutor::TransactionCallbackPresenter.new(user, params, messages)
  end

end