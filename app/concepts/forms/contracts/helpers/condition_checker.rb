# Responsible for running conditions and returning the applicable actions in result
class Forms::Contracts::Helpers::ConditionChecker

  def self.call(contract, conditions, entity, properties, form: {}, row: {})
    result = {}.with_indifferent_access

    # Set the default values of properties
    properties.each do |property|
      result[property] = entity.send(property)
    end


    conditions.each do |condition|
      # Applicable only if the required properties is impact by the condition.
      # This helps in running different conditions at deserialization stage (editable/visible) vs validation stage(required)
      applicable = false
      condition.actions.each do |action|
        next unless properties.blank? or properties.include?(action.property.to_s) or properties.include?(action.property.to_s.to_sym)

        applicable = true
        break
      end
      next unless applicable

      next unless contract.contract_root.profiler.step("condition.apply") { condition.rule.apply?({form: form, row: row}.with_indifferent_access) }
      # match = true
      # condition.rules.each do |rule|
      #   match = false unless rule.match?({form: form, row: row}.with_indifferent_access)
      # end
      # next unless match

      condition.actions.each do |action|
        value = StringUtils.to_bool(action.value)
        result[action.property] = value
      end
    end
    result
  end

end
