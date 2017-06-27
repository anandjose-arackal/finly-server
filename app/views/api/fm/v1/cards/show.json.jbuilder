json.partial! 'card', card: @result.card
json.configurable_restrictions @result.configurable_restrictions
if @result.configurable_restrictions
  json.restrictions do
    card_restriction = @result.restrictions
    card_limits = card_restriction.card_limits

    json.channel_atm card_restriction.channel_atm
    json.channel_ecom_pos card_restriction.channel_ecom_pos
    json.mcc_group_id card_restriction.mcc_group_id
    json.mcc_restriction_type card_restriction.mcc_restriction_type
    json.mcc_group_name card_restriction.mcc_group_name rescue nil

    json.limits do
      json.atm_limits do
        json.array! card_limits.atm_limits.each do |limit|
          json.id limit.id
          json.period_id limit.period_id
          json.period_name limit.period_name rescue nil
          json.budget limit.budget
          json.transactions limit.transactions
          json.enabled limit.allowed
        end
      end
      json.ecom_pos_limits do
        json.array! card_limits.ecom_pos_limits.each do |limit|
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