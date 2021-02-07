class FinlyCollect::Base < BaseHandler

  def env_key
    'finly_collect'
  end

  def parse
    self.parsed_response = JSON.parse(self.response&.body).with_indifferent_access rescue nil
    unless self.parsed_response&.dig(:success)
      message = self.parsed_response&.dig(:messages, :error)
      if message.blank?
        message = 'Unknown error'
      end
      add_message :error, message
    end
  end

  def load_custom_connection(faraday)
    if Rails.env.production?
      config = Finly::SecureStorage::Connector.read('core/finly_collect')&.with_indifferent_access&.dig('outgoing')
      faraday&.basic_auth(config[:username], config[:password])
    else
      faraday&.basic_auth('finly','2dd8284e013bf29c')
    end
  end

  def expect_receivable?
    true
  end

  def success?
    super and self.parsed_response[:success]
  end

  def success
    if expect_receivable?
      params[:receivable] = self.parsed_response[:receivable]
    end
    FinlyCollect::Base::Success.new(user, params, messages)
  end

  class FinlyCollect::Base::Success < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :account_number,
                  :maximum_amount, :minimum_transaction_amount,
                  :maximum_transaction_amount, :exact_transaction_amount,
                  :allowed_transaction_count,
                  :current_account, :savings_account,
                  :neft, :imps, :rtgs, :upi, :date_after,
                  :date_before, :date_on

    def init
      receivable = params[:receivable]
      if receivable.present?
        self.account_number = receivable&.dig(:account_number)
        self.maximum_amount = receivable&.dig(:maximum_amount)
        self.minimum_transaction_amount = receivable&.dig(:minimum_transaction_amount)
        self.maximum_transaction_amount = receivable&.dig(:maximum_transaction_amount)
        self.exact_transaction_amount = receivable&.dig(:exact_transaction_amount)
        self.allowed_transaction_count = receivable&.dig(:allowed_transaction_count)
        self.current_account = receivable&.dig(:current_account)
        self.savings_account = receivable&.dig(:savings_account)
        self.neft = receivable&.dig(:neft)
        self.imps = receivable&.dig(:imps)
        self.rtgs = receivable&.dig(:rtgs)
        self.upi = receivable&.dig(:upi)
        self.date_after = receivable&.dig(:date_after)
        self.date_before = receivable&.dig(:date_before)
        self.date_on = receivable&.dig(:date_on)
      end
    end

  end

end