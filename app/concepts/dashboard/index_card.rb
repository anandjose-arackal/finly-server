class Dashboard::IndexCard < Transactions::API
  include DynamicAttributes

  class_attr :resolver
  class_attr :path
  class_attr :id
  class_attr :created_by, default: :user_id
  class_attr :status
  class_attr :department
  class_attr :location
  class_attr :cost_center
  class_attr :policy

  class_attr :index_route
  class_attr :permissions

  def self.scope_status(*list)
    @scope_status = list.map(&:to_s) if list.present?
    @scope_status
  end

  def self.skip_admin!
    @skip_admin = true
  end

  def self.skip_admin?
    @skip_admin || false
  end

  def self.skip_personal!
    @skip_personal = true
  end

  def self.skip_personal?
    @skip_personal || false
  end

  pass :init
  pass :build_admin_row
  pass :build_personal_row

  def init(context, **)
    context[:data] = []
  end

  def build_admin_row(context, params:, current_user:, **)
    return unless current_user.vendor_payment_admin?
    return if self.class.skip_admin?

    data = {
        type: 'admin',
        data: build_tiles(context)
    }
    context[:data] << data
  end

  def build_personal_row(context, current_user:, **)
    return unless current_user.has_permission?(self.class.permissions) or current_user.vp_admin_or_auditor?
    return if self.class.skip_personal?

    data = {
        type: 'personal',
        data: build_tiles(context, filter_created_by: true)
    }
    context[:data] << data
  end

  def build_tiles(context, filter_created_by: false)
    query = {}
    rule = build_rule(context, filter_created_by: filter_created_by)
    query = rule.as_ransack if rule.present?
    result = IndexBuilder::StatusCount.(params: {route: self.class.index_route, q: query}, current_user: context[:current_user])
    return nil unless result.success?

    result[:counter][:counts].map do |item|
      next if item[:filter_id].present? and self.class.scope_status.present? and not self.class.scope_status.include?(item[:filter_id].to_s)

      {
          title: item[:label],
          count: item[:count],
          url: build_path(item, rule, context)
      }
    end.reject(&:nil?)
  end

  def build_rule(context, filter_created_by: false)
    rule = nil
    params = context[:params]
    if filter_created_by
      rule = add_rule rule, Rules::Builder[self.class.created_by].eq_any(value: context[:current_user].id).with_meta([{id: context[:current_user].id, name: context[:current_user].name}])
    end
    if params[:filter_policy].present? and self.class.policy.present?
      rule = add_rule rule, Rules::Builder[self.class.policy].eq_any(value: params[:filter_policy])
    end
    if (params[:filter_department].present? or params[:filter_sub_department].present?) and self.class.department.present?
      department_id = params[:filter_sub_department] or params[:filter_department]
      rule = add_rule rule, Rules::Builder[self.class.department].eq_any(value: department_id)
    end
    if params[:filter_location].present? and self.class.location.present?
      rule = add_rule rule, Rules::Builder[self.class.location].eq_any(value: params[:filter_location])
    end
    if params[:filter_cost_center].present? and self.class.cost_center.present?
      rule = add_rule rule, Rules::Builder[self.class.cost_center].eq_any(value: params[:filter_cost_center])
    end
    rule
  end

  def build_path(item, rule, context = {})
    params = {
        filter_status: {_id: item[:filter_id]&.to_s, identifier: item[:label]},
        id: (self.class.id || self.class.path)
    }
    if rule.present?
      filter = rule.as_ransack
      params[:input_filters] = {advanced: [filter[:g][:'0']]}
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