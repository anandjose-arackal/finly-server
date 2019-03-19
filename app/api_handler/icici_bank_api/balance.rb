class IciciBankApi::Balance < IciciBankApi::Base

  def icici_bank_action
    'icici_bank_balance_inquiry'
  end

  def raw_api_params
    {
        AGGRID: self.company_details[:AGGR_ID],
        CORPID: self.company_details[:CORP_ID],
        USERID: self.company_details[:USER_ID],
        URN: self.company.icici_bank_config.urn,
        UNIQUEID: self.icici_bank_transaction.unique_request_number
    }
  end

  def post_params
    encrypt_params(
        raw_api_params
    )
  end
end