class Filters::Handler
  attr_accessor :query, :validation

  def initialize(query)
    self.query = query
  end

  def valid?
    self.validation = Filters::Schema::Validation.check(query)
    self.validation.success?
  end

  def errors
    valid? unless self.validation.present?
    return nil if validation.success?

    validation.failure
  end

  def within_scope?(record)
    filter(record.class.where(id: record.id)).count > 0
  end

  def filter(collection)
    collection.ransack(self.query).result(distinct: true)
  end

end