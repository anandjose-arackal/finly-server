class Masters::Currencies::Resolver < Resolver::API

  entity Currency

  def load(params)
    Currency.all
    # user.company.form_currencies.non_deleted
  end

end