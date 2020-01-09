class Docs::UtilityBills::Subscriptions::Configs::BillerType < Transactions::API

  schema do
    params do
      optional(:type).filled
    end
  end

  step :init

  def init(options, params:, current_user:, **)
    # biller_types = [
    #     {name: "Broadband Prepaid", field_name: "Operator"},
    #     {name: "Broadband Postpaid", field_name: "Operator"},
    #     {name: "Cable",field_name: "Operator"},
    #     {name: "Mobile Postpaid", field_name: "Operator"},
    #     {name: "DTH", field_name: "Operator"},
    #     {name: "Electricity", field_name: "Board"},
    #     {name: "Landline Postpaid", field_name: "Operator"},
    #     {name: "Water", field_name: "Board"},
    #     {name: "Mobile Prepaid", field_name: "Operator"},
    #     {name: "Gas", field_name: "Operator"}
    # ]

    field_names = {
        "Broadband Prepaid": "Operator",
        "Broadband Postpaid": "Operator",
        "Cable": "Operator",
        "Mobile Postpaid": "Operator",
        "DTH": "Operator",
        "Electricity": "Board",
        "Landline Postpaid": "Operator",
        "Water": "Board",
        "Mobile Prepaid": "Operator",
        "Gas": "Operator"
    }

    bbps_biller_types = BbpsBiller.all.pluck(:biller_category_name).uniq.compact

    biller_types = bbps_biller_types.map {|item| {name: item, field_name: (field_names[item] || "Operator")}}

    type = params[:type]


    biller_type = biller_types.filter{|item| item[:name] == type}.first

    billers_op = Docs::UtilityBills::Billers::Ops::Index.({params: {filter_category_name: type}, current_user: current_user})

    bbps_billers = billers_op['result']['bbps_billers']


    options['result'] = {}
    options['result']['fields'] = {
        name: biller_type[:field_name],
        type: 'dropdown',
        values: bbps_billers.as_json(autocomplete: true)
    }
  end
end