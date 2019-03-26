# this will handle registration callbacks for all registrations in the system
# currently we have nothing to do with this, so just logging the request and letting it be
class BankTransfer::IciciCallbacks::RegistrationCallbackExecutor < BaseOperation

  attr_accessor :aggr_id, :corp_id, :user_id, :urn, :status

  def init

  end

end
