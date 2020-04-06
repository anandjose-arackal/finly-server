class Masters::PaymentTerms::Resolver < Resolver::API

  entity PaymentTerm

  def load(params)
    user.company.payment_terms
  end

end