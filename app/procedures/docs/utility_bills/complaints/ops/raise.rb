class Docs::UtilityBills::Complaints::Ops::Raise < Transactions::API
  schema do
    params do

    end
  end

  step :init
  step :raise
  step :post_process


  def init(options, params:, **)

  end
end