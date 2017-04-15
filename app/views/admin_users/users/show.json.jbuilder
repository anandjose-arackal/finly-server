if @result.selected_user.first_name.present?
  json.extract! @result.selected_user, :first_name, :last_name, :mobile_number, :email, :address_1, :address_2, :pin_code, :city, :state_name,
                                     :company_name, :id, :mothers_maiden_name, :active


  json.date_of_birth (@result.selected_user.date_of_birth.strftime("%d-%m-%Y"))
  json.gender (@result.selected_user.gender_name)
else
  json.email @result.selected_user.email
  json.mobile_number @result.selected_user.mobile_number
end

json.cards do
  json.array!(@result.cards) do |card|
    json.type card.card_program_name
    json.proxy card.proxy
    json.ending_number card.ending_number
    json.active card.active
    json.id card.id
  end
end

json.roles do
  json.admin @result.selected_user.admin?
  json.finance_manager @result.selected_user.finance_manager?
  json.manager @result.selected_user.manager?
end


# all mapping for this particular user
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

[:managers, :finance_managers].each do |key|
  managers = @result.send(key)
  next if managers.blank?
  json.set! key, managers do |manager|
    json.id manager.id
    json.name manager.name
    json.email manager.email
  end
end