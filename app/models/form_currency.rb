# == Schema Information
#
# Table name: form_currencies
#
#  id            :bigint           not null, primary key
#  currency      :string(255)
#  currency_code :string(255)
#  symbol        :string(255)
#  company_id    :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  deleted_at    :datetime
#
class FormCurrency < NonTenantedApplicationRecord

  def currency_conversion_rate(date, to_iso_code)
    ExchangeRate.get_rate(
        date,
        self.currency_code,
        to_iso_code
    ).to_f
  end
end
