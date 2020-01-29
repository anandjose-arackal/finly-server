class Transactions::Contract < Reform::Form

  def add_schema_errors(errors_list)
    errors_list.to_h.each do |attr, err_list|
      errors.add attr, err_list
    end
  end

  def self.property(name, options = {}, &block)
    args = {contract: self, type: :property, name: name, options: options, block: block}
    Transactions::Contracts::PreProcessor.execute(args)
    super(args[:name], args[:options], &args[:block])
  end

  def self.collection(name, options = {}, &block)
    args = {contract: self, type: :property, name: name, options: options, block: block}
    Transactions::Contracts::PreProcessor.execute(args)
    super(args[:name], args[:options], &args[:block])
  end

end