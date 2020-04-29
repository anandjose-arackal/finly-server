class Docs::UtilityBills::Bills::Ops::BillParser < Transactions::API

  # ##
  # Used to parse bill data from response
  # ##

  schema do
    params do
      required(:data).filled
    end
  end

  step :parse

  def parse(options, params:, **)
    data = params[:data]

    additional_info = get_additional_info(data)

    result = {
        amount: (data.amount.to_d / 100).round(2),
        bill_date: data.bill_date,
        bill_number: data.bill_number,
        due_date: data.due_date,
        bill_month: additional_info[:bill_month],
        bill_period: data.bill_period,
        autofetched: params[:autofetched] || true,
        order_number: data.ref_no,
        order_number_type: "BillFetch",

        early_payment_fee: (additional_info[:early_payment_amount].to_d / 100).round(2),
        late_payment_fee: (additional_info[:late_payment_amount].to_d / 100).round(2),
        early_payment_date: additional_info[:early_payment_date],
        disconn_tag: additional_info[:disconn_tag],
        pc: additional_info[:pc],
        api_response: data.as_json&.dig("table")
    }

    options[:result] = result
  end

  def get_additional_info(data)
    %i(
      convenience_fee convenience_fee_desc early_payment_fee late_payment_fee
      additional_field_1 additional_field_2 additional_field_3 additional_field_4
      additional_field_5 additional_field_6
    ).map {|key| data.send(key)}.
        reject {|item| !item.index("=")}.
        map {|item| {"#{item.split("=")[0].gsub(" ", "_").downcase}": item.split("=")[1]}}.
        reduce({}, :merge).
        with_indifferent_access
  end
end
