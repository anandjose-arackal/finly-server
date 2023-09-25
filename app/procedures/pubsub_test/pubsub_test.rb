class PubsubTest < Transactions::API
  include Events::Consumer

  consumes_event! 'invoice.create'

  def work(user, payload)
    self.class.(params: payload, current_user: user)
  end

  step :check!

  def check(options:, params:, **)
    binding.pry
    return true
  end
end
