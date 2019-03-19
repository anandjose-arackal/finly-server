class IciciBankApi::TransactionInitiate < IciciBankApi::Base

  attr_accessor :payment, :icici_bank_transaction, :transfer_request

  def init
    self.payment = params[:payment]
    self.icici_bank_transaction = params[:icici_bank_transaction]
    self.receiving_account = self.icici_bank_transaction.receiving_account
    self.transfer_request = params[:transfer_request]
  end

  def icici_bank_action
    'transaction_initiate'
  end

  def post_params
    encrypt_params(
        AGGRID: self.company_details[:AGGR_ID],
        AGGRNAME: self.company_details[:AGGR_NAME],
        CORPID: self.company_details[:CORP_ID],
        USERID: self.company_details[:USER_ID],
        URN: self.company.icici_bank_config.urn,
        UNIQUEID: self.transfer_request.unique_request_number,
        DEBITACC: self.company_details[:DEBIT_ACC_NO],
        CREDITACC: self.receiving_account.account_number,
        IFSC: self.receiving_account.ifsc,
        AMOUNT: self.icici_bank_transaction.amount.value,
        CURRENCY: self.icici_bank_transaction.amount.currency.country_code,
        TXNTYPE: self.icici_bank_transaction.transfer_type,
        PAYEENAME: self.receiving_account.account_owner.name,
        REMARKS: self.payment.note,
        CUSTOMERINDUCED: "N"
    )
  end

  def parse

  end

end