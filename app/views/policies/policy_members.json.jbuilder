json.members do
  json.array!(@result.users) do |mapping|
    json.id mapping[:user].id
    json.name mapping[:user].name
    json.policy do
      json.id @result.policy.id
      json.name @result.policy.name
    end
    [:default, :conditional_manager, :conditional_finance_manager,
     :conditional_approves_to, :conditional_approves_finance_to].each do |key|
      json.set! key do
        maps = mapping[key]
        next if maps.blank?
        if key == :default
          map = maps
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
  end
end

json.users do
  json.array!(@result.users) do |user|
    json.email user.email
    json.name user.name
    json.mobile_number user.mobile_number
    json.manager user.team_mapping.policy(@result.policy).manager.first&.email
    json.finance_manager user.team_mapping.policy(@result.policy).finance_manager.first&.email
    json.approves_to user.team_mapping.policy(@result.policy).approves_to.first&.email
    json.approves_finance_to user.team_mapping.policy(@result.policy).approves_finance_to.first&.email
  end
end