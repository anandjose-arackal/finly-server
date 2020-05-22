# Responsible for running conditions and returning the applicable actions in result
class Forms::Contracts::Helpers::ComputeRunner

  def self.call(represented, entity, value, form: {}, row: {})
    case entity.compute_type_id
    when FormEntityComputationType.id_for(:lookup)
      compute_via_lookup(represented, entity, value, form: form, row: row)
    when FormEntityComputationType.id_for(:form)
      compute_via_form(represented, entity, value, form: form, row: row)
    else
      # Do nothing
    end
  end

  def self.compute_via_lookup(represented, entity, value, form: {}, row: {})
    lookup_value = Forms::RequestParser.new(form: form, row: row).fetch(entity.compute_lookup_entity.entity_path)
    return unless lookup_value.present?

    # Use the document owner or the current user for fetching the lookup choices
    user = represented.contract_root.respond_to?(:created_by) ? represented.contract_root.created_by : RequestStoreUtil.current_user
    return unless user.present?

    lookup_record = entity.compute_lookup_entity.choices_scope.find_by_id(lookup_value, params: {}, user: user)
    return unless lookup_record.present?

    value = lookup_record.to_exposure.template(entity.compute_formula)
    represented.send("#{entity.entity_key}=", value)
  end

  def self.compute_via_form(represented, entity, value, form: {}, row: {})
    value = LiquidHelper.interpolate(entity.compute_formula, {row: row, form: form}.as_json)
    represented.send("#{entity.entity_key}=", value)
  end
end
