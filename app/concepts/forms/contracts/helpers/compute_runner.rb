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

  end

  def self.compute_via_form(represented, entity, value, form: {}, row: {})
    value = LiquidHelper.interpolate(entity.compute_formula, row.merge(form: form))
    represented.send("#{entity.entity_key}=", value)
  end
end
