json.user do
  json.name @result.selected_user.name
  json.email @result.selected_user.email
  json.mobile_number @result.selected_user.mobile_number
  json.current_user_id @result.user.id
  json.editable @result.user.company_admin?
end
json.role do
  json.admin @result.roles[:admin]
  json.manager @result.roles[:manager]
  json.finance_manager @result.roles[:finance_manager]
  json.editable do
    admin = @result.user.company_admin?
    json.admin (admin and not @result.selected_user == @result.user)
    json.manager (admin or @result.user.manager?)
    json.finance_manager (admin or @result.user.finance_manager?)
  end
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
end
[:team_managers, :team_finance_managers].each do |key|
  managers = @managers.send(key)
  next if managers.blank?
  json.set! key, managers do |manager|
    json.id manager.id
    json.name manager.name
    json.email manager.email
  end
end
json.actions @result.actions
json.card do
  assigned = @result.selected_user.cards.present?
  json.assigned assigned
  if assigned
    card = @result.selected_user.cards.first
    json.extract! card, :ending_number, :description, :active, :serial_id
  end
end