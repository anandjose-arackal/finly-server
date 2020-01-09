class Docs::UtilityBills::Billers::Ops::Index < Transactions::API
  include HasScope

  has_scope :filter_search
  has_scope :filter_category_name

  # step Transactions::Authorization::Roles(:utility_bill_master_initiator)
  step :init


  def init(options, params:, **)
    bbps_billers = BbpsBiller.all

    bbps_billers = apply_scopes(bbps_billers, params)

    options['result'] = {
        "bbps_billers" => bbps_billers
    }
  end
end