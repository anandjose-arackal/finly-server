class Dashboard::Card < Transactions::API
  include DynamicAttributes

  class_attr :resolver
  class_attr :path
  class_attr :created_by, default: :user_id
  class_attr :status
  class_attr :department, default: :department_id
  class_attr :location, default: :location_id
  class_attr :cost_center, default: :cost_center_id
  class_attr :policy, default: :policy_id

  def self.rows
    @rows ||= []
  end

  def self.row(type, options = {}, &block)
    rows << Dashboard::Row.new(type, options, &block)
  end

  step :build_rows

  def build_rows(context, params:, **)
    context[:data] = self.class.rows.map do |row|
      build_row(row, context)
    end
  end

  def build_row(row, context)
    {
        type: row.type,
        data: row.tiles.map { |tile| build_tile(tile, context) }
    }
  end

  def build_tile(tile, context)
    rule = build_rule(tile, context)
    count = count(tile, rule, context)
    path = build_path(tile, rule, context)
    {
        title: tile.title,
        count: count,
        url: path
    }
  end

  def build_rule(tile, context)
    rule = nil
    params = context[:params]
    if tile.filter_created_by
      rule = add_rule rule, Rules::Builder[self.class.created_by].eq_any(value: context[:current_user].id)
    end
    if params[:filter_policy].present?
      rule = add_rule rule, Rules::Builder[self.class.policy].eq_any(value: params[:filter_policy])
    end
    if params[:filter_department].present? or params[:filter_sub_department].present?
      department_id = params[:filter_sub_department] or params[:filter_department]
      rule = add_rule rule, Rules::Builder[self.class.department].eq_any(value: department_id)
    end
    if params[:filter_location].present?
      rule = add_rule rule, Rules::Builder[self.class.location].eq_any(value: params[:filter_location])
    end
    if params[:filter_cost_center].present?
      rule = add_rule rule, Rules::Builder[self.class.cost_center].eq_any(value: params[:filter_cost_center])
    end
    rule
  end

  def count(tile, rule, context)
    query = {}
    if tile.filter_status
      rule = add_rule rule, Rules::Builder[self.class.status].eq_any(value: tile.filter_status)
    end
    if rule.present?
      query = rule.as_ransack
    end
    records = Resolver::Router.dispatch(self.class.resolver, current_user: context[:current_user], params: {q: query})
    records.count
  end

  def build_path(tile, rule, context)
    params = {
        filter_status: {_id: tile.filter_status&.to_s, identifier: tile.title},
        id: self.class.path
    }
    if rule.present?
      filter = rule.as_ransack
      params[:input_filters] = {advanced: [filter[:g][:'0']]}
      params[:q] = filter
    end
    "#{self.class.path}/params=#{params.to_json}"
  end

  def add_rule(rule_1, rule_2)
    if rule_1.present?
      rule_1.and(rule_2)
    else
      rule_2
    end
  end

end