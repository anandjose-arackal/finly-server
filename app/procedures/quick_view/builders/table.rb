class QuickView::Builders::Table < QuickView::Builders::Entity

  attr_accessor :resolver, :params, :paginate, :search, :data

  register :table

  def value(options={})
    val = super(options) || self.data
    return val if val.present?

    evaluated_params = {}
    if params.present?
      evaluated_params = LiquidHelper.interpolate(self.params, { "params" => options[:params] }.with_indifferent_access)
    end

    param = RequestStoreUtil.request_params || {}
    param = param.deep_merge(evaluated_params).with_indifferent_access

    if resolver.present?
      return Resolver::Transactions::Resolve.with({params: param, current_user: options[:current_user]}, route: resolver, paginate: paginate, filter: true)
    end

    nil
  end

end
