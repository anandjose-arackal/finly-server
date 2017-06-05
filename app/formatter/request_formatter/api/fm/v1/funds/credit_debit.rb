class RequestFormatter::Api::Fm::V1::Funds::CreditDebit < RequestFormatter::Base

  def process
    self.formatted_request = format_file(__dir__, 'credit_debit.yaml.erb', user, params)
  end

end