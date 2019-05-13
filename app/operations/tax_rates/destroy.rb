class TaxRates::Destroy < TaxRates::Base

  attr_accessor :tax_rate

  def init
    self.company = user.company
    id = params[:id] || params[:tax_rate_id]
    self.tax_rate = self.company.tax_rates.find_by(id: id)
  end

  def process
    unless self.tax_rate.destroy
      add_message :error, self.tax_rate.errors.full_messages
      return
    end
  end

  def post_process
    add_message :success, "Tax rates destroyed"
  end
end