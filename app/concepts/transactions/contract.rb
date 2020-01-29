class Transactions::Contract < Reform::Form

  def add_schema_errors(errors_list)
    errors_list.to_h.each do |attr, err_list|
      errors.add attr, err_list
    end
  end

  def self.property(name, options = {}, &block)
    Transactions::Contracts::Sanitizer.sanitize(self, :property, name, options, block)
    super(name, options, &block)
  end

  def self.collection(name, options = {}, &block)
    Transactions::Contracts::Sanitizer.sanitize(self, :collection, name, options, block)
    super(name, options, &block)
  end

end