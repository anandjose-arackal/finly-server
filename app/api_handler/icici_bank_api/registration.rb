class IciciBankApi::Registration < IciciBankApi::Base

  attr_accessor :company

  def init
    super

  end

  def post_params
    encrypt_params(
        AGGRID: self.company_details[:AGGR_ID],
        AGGRNAME: self.company_details[:AGGR_NAME],
        CORPID: self.company_details[:CORP_ID],
        USERID: self.company_details[:USER_ID],
        ALIASID: self.company.icici_bank_config.alias_id,
        URN: self.company.icici_bank_config.urn
    )
  end
end