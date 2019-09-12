class Transactions::Resolver

  def self.Model(model, scope: :default, filter: false, paginate: false)
    ->(input, options) {Resolve.with(input, model, scope, filter, paginate)}
  end

  class Resolve
    def self.with(options, model, scope, filter, paginate)
      options['model.index'] = model.resolve(scope)

      # Todo filter and pagination
      if filter
        options['model.index.filtered'] = options['model.index'].ransack(options&.dig('params', :q))
      end

      if paginate
        page = params[:page] || 1
        per_page = params[:per_page] || 30
        options['model.index.paginated'] = options['model.index.filtered'].paginate(page: page, per_page: per_page)
      end

      true
    end
  end

end