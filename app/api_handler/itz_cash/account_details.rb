class ItzCash::AccountDetails < ItzCash::Base

  def path
    'myaccount/servlet/ItzCashAccountDetailsServlet'
  end

  def post_params
    {serialid: user.cards.first.serial_id, itzmodule: Constants::ITZCASH_MODULE}
  end

end