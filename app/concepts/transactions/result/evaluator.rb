module Transactions::Result::Evaluator

  def self.eval_result(options, result)
    if result.success?
      # Success

      return true
    end

    # Failure
    result.errors.each do |key, value|
      options[key] = value
    end
    false
  end

  def eval_result(options, result)
    Transactions::Result::Evaluator.eval_result(options, result)
  end

end
