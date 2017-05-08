json.company_card_enabled @result.user.company.itz_cash_property.d_code.present? rescue false
json.user do
  json.name @result.selected_user.name
  json.email @result.selected_user.email
  json.mobile_number @result.selected_user.mobile_number
  json.current_user_id @result.user.id
  json.gender @result.selected_user.profile.gender rescue nil
  json.editable (@result.user.company_admin? and params[:view] == 'admin')
  json.activateable @result.selected_user.manager_activateable?
  json.enforce_policy do
    json.enabled @result.selected_user.enforce_policy_enabled?
    approver = (@result.selected_user.manager? or @result.selected_user.finance_manager?)
    json.approver approver
    json.non_approver !approver
  end
end
json.role do
  json.admin @result.roles[:admin]
  json.manager @result.roles[:manager]
  json.finance_manager @result.roles[:finance_manager]
  json.editable do
    admin = (@result.user.company_admin? and params[:view] == 'admin')
    json.admin (admin and not @result.selected_user == @result.user)
    json.manager (admin or (@result.user.manager? and params[:view] == 'manager'))
    json.finance_manager (admin or (@result.user.finance_manager? and params[:view] == 'finance_manager'))
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

json.cards do
  json.array! @result.cards.each do |card_details|
    card = card_details[:card]
    actions = card_details[:actions]

    json.card card

    if card[:configurable_restrictions]
      json.restrictions do

        card_restriction = card_details[:card_restriction]
        card_limits = card_restriction.card_limits

        json.channel_atm card_restriction.channel_atm
        json.channel_ecom_pos card_restriction.channel_ecom_pos
        json.mcc_group_id card_restriction.mcc_group_id
        json.mcc_restriction_type card_restriction.mcc_restriction_type
        json.mcc_group_name card_restriction.mcc_group_name rescue nil

        json.limits do
          json.atm_limits do
            json.array! card_limits.ecom_pos_limits.each do |limit|
              json.id limit.id
              json.period_id limit.period_id
              json.period_name limit.period_name rescue nil
              json.budget limit.budget
              json.transactions limit.transactions
              json.enabled limit.allowed
            end
          end
          json.ecom_pos_limits do
            json.array! card_limits.atm_limits.each do |limit|
              json.id limit.id
              json.period_id limit.period_id
              json.period_name limit.period_name rescue nil
              json.budget limit.budget
              json.transactions limit.transactions
              json.enabled limit.allowed
            end
          end
        end
      end
    end

    json.actions actions

  end
end

json.mcc_groups do
  json.array! @result.mcc_groups.each do |mcc_group|
    json.extract! mcc_group, :id, :name
  end
end

json.wallet do
  json.balance @result.wallet.balance_value
end

json.auto_submit_config do
  json.extract! @result.auto_submit_config, :enabled, :limit_to_card_expenses, :default_memo
  json.period do
    json.id @result.auto_submit_config.period_id
    period_name = nil
    if @result.auto_submit_config.period_id.present?
      period_name = @result.auto_submit_config.period.name
    end
    json.name period_name
  end
  json.policy do
    json.id @result.auto_submit_config.default_policy_id
    policy_name = nil
    if @result.auto_submit_config.default_policy_id.present?
      policy_name = @result.auto_submit_config.default_policy.name
    end
    json.name policy_name
  end
end
json.policies do
  json.array! @result.policies do |policy|
    json.extract! policy, :id, :name
  end
end
json.periods do
  json.array! @result.periods do |period|
    json.extract! period, :id, :name
  end
end
json.groups do
  json.array! @result.user_groups.each do |group|
    json.id group.id
    json.name group.name
    json.items do
      json.array group.user_group_items.each do |item|
        json.id item.id
        json.name item.name
        json.set_as_user_group_item @result.user_group_item_mappings.with_group(group.id).with_group_item(item.id)&.first.present? ? true : false
      end
    end
  end
end