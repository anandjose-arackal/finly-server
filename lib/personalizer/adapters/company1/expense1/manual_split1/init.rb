class Personalizer::Adapters::Company1::Expense1::ManualSplit1::Init < Personalizer::Adapters::Base

  def pre_validate
    if params.blank?
      add_message :error, 'Error loading configuration'
    end
  end

  def validate
    # params&.dig(:splits).each do |key, value|
    #   quantity = value.dig(:custom_fields, '35')
    #   unless quantity.present?
    #     add_message :error, "Split #{key}: Quantity cannot be blank"
    #     return
    #   end
    #   unless StringUtils.is_number? quantity
    #     add_message :error, "Split #{key}: Quantity is not a number"
    #     return
    #   end
    #   price_per_quantity = value.dig(:custom_fields, '34')
    #   unless price_per_quantity.present?
    #     add_message :error, "Split #{key}: Price Per Unit cannot be blank"
    #     return
    #   end
    #   unless StringUtils.is_number? price_per_quantity
    #     add_message :error, "Split #{key}: Price Per Unit is not a number"
    #   end
    #   if has_errors?
    #     return
    #   end
    # end
  end

  def process
    params&.dig(:splits).each do |key, value|
      quantity = value.dig(:custom_fields, '34')
      price_per_quantity = value.dig(:custom_fields, '35')
      if quantity.present? and price_per_quantity.present?
        value[:amount_attributes][:value] = (quantity.to_i * price_per_quantity.to_i)
      end
    end
  end

end