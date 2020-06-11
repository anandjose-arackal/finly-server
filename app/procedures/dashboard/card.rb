class Dashboard::Card < Transactions::API
  include DynamicAttributes

  class_attr :resolver
  class_attr :path
  class_attr :created_by, default: :user_id

  def rows
    @rows ||= []
  end

  def self.row(options={}, &block)
    rows << Dashboard::Row.new(options, &block)
  end

  step :build_rows

  def build_rows(context, params:, **)
    context[:rows] = row.map do |row|
      row.build(card)
    end
  end

end