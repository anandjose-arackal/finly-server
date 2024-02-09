class TaxRates::Create < TaxRates::Base

  attr_accessor :tax_params

  def init
    self.company = user.company
    self.tax_params = tax_rate_params
  end

  def authorized_user_types
    [:company_admin, :vendor_payments_admin]
  end

  def validate
    if self.tax_rate_params[:rate]&.to_i < 0
      add_message :error, 'Tax value should not be negative'
    end
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