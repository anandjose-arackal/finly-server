class IciciBankApi::TransactionStatus < IciciBankApi::Base

  attr_accessor :icici_bank_transaction

  def init
    self.icici_bank_transaction = params[:icici_bank_transaction]
  end

  def icici_bank_action
    'transaction_status'
  end

  def post_params
    encrypt_params(
        AGGRID: self.company_details[:AGGR_ID],
        CORPID: self.company_details[:CORP_ID],
        USERID: self.company_details[:USER_ID],
        URN: self.company.icici_bank_config.urn,
        UNIQUEID: self.icici_bank_transaction.unique_request_number
    )
  end

end