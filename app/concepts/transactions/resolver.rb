class Transactions::Resolver

  def self.Model(model, scope: :default, filter: false, paginate: false)
    ->(input, options) {Resolve.with(input, model, scope, filter, paginate)}
  end

  class Resolve
    def self.with(options, model, scope, filter, paginate)
      options['model.index'] = model.resolve(scope)
      # Todo filter and pagination
      # if filter
      #   options['model.index.filtered']
      # end
      # if paginate
      #   options['model.index.paginated']
      # end
      true
    end
  end

end