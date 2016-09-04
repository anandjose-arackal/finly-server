json.user do
  json.name @result.user.name
  json.email @result.user.email
end
json.role do
  json.admin @result.roles[:admin]
  json.manager @result.roles[:manager]
  json.finance_manager @result.roles[:finance_manager]
end
json.mapping @result.mapping.each do |mapping|
  json.company_default mapping[:company_default]
  if mapping[:policy]
    json.policy do
      json.id mapping[:policy].id
      json.name mapping[:policy].name
    end
  end
  [:default, :conditional_manager, :conditional_finance_manager,
   :conditional_approves_to, :conditional_approves_finance_to].each do |key|
    json.set! key do
      map = mapping[key]
      next if map.blank?
      json.mapping_id map.id
      if map.greater_than_amount_id.present?
        json.greater_than_amount do
          json.id map.greater_than_amount_id
          json.value map.greater_than_amount.value
          json.currency_id map.greater_than_amount.currency_id
        end
      end
      [:manager, :finance_manager, :approves_to, :approves_finance_to].each do |k|
        if map.send("#{k}_id").present?
          json.set! k do
            json.id map.send("#{k}_id")
            json.name map.send(k).name
          end
        end
      end
    end
  end

end