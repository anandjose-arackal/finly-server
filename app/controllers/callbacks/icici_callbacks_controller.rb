class Callbacks::IciciCallbacksController < PublicBase

  # todo - add IP whitelisting to this API

  # this is the callback that will accept successful registrations and
  # trigger whatever associated logic we have in our system
  def registrations

  end

  # this is the callback that will accept successful transactions
  # and trigger whatever associated logic we have wrt to the payment
  def transactions
    # for now just saving the details into a model - can later be changed to the operation
    IciciTransactionCallback.create(
                                AGGRNAME: params[:AGGRNAME],
                                AGGRID: params[:AGGRID],
                                URN: params[:URN],
                                UNIQUEID: params[:UNIQUEID],
                                REQUESTID: params[:REQUESTID],
                                TXNSTATUS: params[:TXNSTATUS],
                                UTRNUMBER: params[:UTRNUMBER],
                                CORPID: params[:CORPID],
                                USERID: params[:USERID]
    )
  end

end