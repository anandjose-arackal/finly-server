class ItemIndex < Searchkick::Api::DSL

  scope do
    includes(:item_expense_type, :product_type, :supply_item_type, :category)
  end

  record_type 'items'

  field :description, value: ->(record) { record.description }
  field :category_name, value: ->(record) { record.category&.name }
  field :category_code, value: ->(record) { record.category&.category_code }
  field :sequence_id, value: ->(record) { record.item_number }
  field :gl_code, value: ->(record) { record.category&.gl_code }
  field :status_name, value: ->(record) { 'Active' }

  def self.should_index?(record)
    record.deleted_at.nil? and record.active
  end

  # included do
  #   scope :searchkick_import, -> {
  #     includes(:item_expense_type, :product_type, :supply_item_type, :category)
  #   }
  #
  #   searchkick_record_type :items
  # end
  #
  # def searchkick_data
  #   {
  #       description: description,
  #       category_name: category&.name,
  #       category_code: category&.category_code,
  #       sequence_id: item_number,
  #       gl_code: category&.gl_code,
  #       status_name: 'Active'
  #   }
  # end
  #
  # def should_index?
  #   deleted_at.nil? and active
  # end

  # index Indexes::Vp do
  #   include_associations :item_expense_type, :product_type, :supply_item_type, :category
  #
  #   document_type :items
  #   permissions Masters::Items::Index.permissions
  #   category :masters
  #   route 'inventory/{{record_id}}/params={}'
  #   layout(
  #       {
  #           fixed_left: [:description, :sequence_id],
  #           fixed_right: [:category_name, :status_name]
  #       }
  #   )
  #
  #   serialize do |record|
  #     {
  #         description: record.description,
  #         category_name: record.category&.name,
  #         category_code: record.category&.category_code,
  #         sequence_id: record.item_number,
  #         gl_code: record&.category&.gl_code,
  #         status_name: 'Active',
  #         company_id: record.company_id.to_s
  #     }
  #   end
  #
  #   condition do |record|
  #     record.deleted_at.nil? and record.active
  #   end
  #
  # end

end