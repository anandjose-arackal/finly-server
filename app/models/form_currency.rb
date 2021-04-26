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

  def currency_conversion_rate
    ExchangeRate.get_rate(
        Date.yesterday,
        self.currency_code,
        RequestStoreUtil.current_user.company.reporting_currency_code
    ).to_f rescue 1
  end
end
