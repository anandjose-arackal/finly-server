class ItzCash::AccountDetails < ItzCash::Base

  def path
    'myaccount/servlet/ItzCashAccountDetailsServlet'
  end

  def post_params
    {serialid: 'S00017740090', itzmodule: 'FINLY'}
  end

end