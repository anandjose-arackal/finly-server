class IciciBankApi::TransactionOtp < IciciBankApi::Base



  def post_params
    encrypt_params(
        AGGRID: self.company_details[:AGGR_ID],
        AGGRNAME: self.company_details[:AGGR_NAME],
        CORPID: self.company_details[:CORP_ID],
        USERID: self.company_details[:USER_ID],
        URN: self.company.icici_bank_config.urn,
        UNIQUEID: "GENERATED UNIQUE ID"
    )
  end
end