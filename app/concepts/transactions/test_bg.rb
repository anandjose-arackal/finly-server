class Transactions::TestBg < Transactions::API
  include BackgroundWorker

  pass :step_test

  def step_test(context, input)
    context[:a] = 1
    true
  end

end