mapping = @result.map
json.user_name map[:user]&.name
json.policy_admin current_user.policy_admin?
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
    maps = mapping[key]
    next if maps.blank?
    if key == :default
      map = maps.first rescue nil
      next if map.blank?
      json.mapping_id map.id
      if map.greater_than_amount_id.present?
        json.greater_than_amount do
          # json.id map.greater_than_amount_id
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
    else
      json.array! maps do |map|
        json.mapping_id map.id
        if map.greater_than_amount_id.present?
          json.greater_than_amount do
            # json.id map.greater_than_amount_id
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
end