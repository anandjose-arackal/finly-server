class Filters::Predicates

  #  'lteq_days', # Name your predicate
  #  # What non-compound ARel predicate will it use? (eq, matches, etc)
  #  arel_predicate: 'lteq',
  #  # Format incoming values as you see fit. (Default: Don't do formatting)
  #  formatter: proc { |v| debugger; v },
  #  # Validate a value. An "invalid" value won't be used in a search.
  #  # Below is default.
  #  validator: proc { |v| v.present? },
  #  # Should compounds be created? Will use the compound (any/all) version
  #  # of the arel_predicate to create a corresponding any/all version of
  #  # your predicate. (Default: true)
  #  compounds: false,
  #  # Force a specific column type for type-casting of supplied values.
  #  # (Default: use type from DB column)
  #  type: :string,
  #  # Use LOWER(column on database).
  #  # (Default: false)
  #  case_insensitive: fa[]lse

  def self.predicates
    @predicates ||= {}
  end

  def self.register(predicate, config)
    predicates[predicate] = config
  end

  register :lteq_days, {
      arel_predicate: 'lteq',
      formatter: proc { |value| (Date.today - value) },
      compounds: false,
      type: :integer
  }

  register :gteq_days, {
      arel_predicate: 'gteq',
      formatter: proc { |value| (Date.today - value) },
      compounds: false,
      type: :integer
  }

  register :eq_days, {
      arel_predicate: 'eq',
      formatter: proc { |value| (Date.today - value) },
      compounds: false,
      type: :integer
  }

  register :in_days, {
      arel_predicate: 'eq',
      formatter: proc { |value| (Date.today + value) },
      compounds: false,
      type: :integer
  }

  # Added this as a work around for not_null not generating correct query for nested relationships
  register :null_not, {
      arel_predicate: 'not_eq',
      formatter: proc { |value| nil },
      compounds: false,
  }

  def self.setup(config)
    predicates.each do |predicate, conf|
      config.add_predicate predicate, conf
    end
  end

end