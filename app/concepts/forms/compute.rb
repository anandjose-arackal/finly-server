class Forms::Compute

  def self.Form(formula)
    { form: { formula: formula } }
  end

  def self.Lookup(lookup_entity_path, formula, assignments: nil)
    { lookup: { lookup_entity_path: lookup_entity_path, formula: formula, assignments: assignments } }
  end

end