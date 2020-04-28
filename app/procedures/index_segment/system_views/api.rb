class IndexSegment::SystemViews::API
  include DynamicAttributes

  class_attr :label
  class_attr :columns
  class_attr :permissions

  def self.screen(handle)
    @screen = handle
    IndexSegment::SystemViews::Registry.register handle, self
  end

  def self.filters
    @filters ||= []
  end

  def self.filter(attribute, predicate, value, field_id: nil)
    filters << {a: attribute, p: predicate, v: value, field_id: (field_id || attribute)}
  end

  def self.build(user)
    return nil unless has_permission?(user)

    {
        name: label,
        filters: build_filters(user),
        default: false,
        columns: columns
    }
  end

  def self.build_filters(user)
    query = {
        logic_type: :group,
        m: :and,
        c: []
    }
    filters.each do |filter|
      query[:c] << {a: {"0": {name: filter[:a], field_id: filter[:field_id]}, ransack_args: {}}, p: filter[:p], v: {"0": {value: filter[:v]}}}
    end
    {q: query}
  end

  def self.has_permission?(user)
    return true if permissions.blank?
    return true if permissions.include?(:admin) and user.admin?(RequestStoreUtil.current_app)
    return true if user.has_roles?(permissions)

    false
  end

end