class TaxRates::Create < TaxRates::Base

  attr_accessor :tax_params

  def init
    self.company = user.company
    self.tax_params = tax_rate_params
  end

  def process
    rate = self.company.tax_rates.build(self.tax_params)
    unless rate.save
      add_message :error, rate.errors.full_messages
      return
    end
  end

  def post_process
    add_message :success, "Tax rates created"
  end

end