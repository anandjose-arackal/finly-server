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

  def self.filter(attribute, predicate, value)
    filters << {a: attribute, p: predicate, v: value}
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
      query[:c] << {a: {"0": {name: filter[:a]}}, p: filter[:p], v: {"0": {value: filter[:v]}}}
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