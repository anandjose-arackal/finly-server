class ImportRecord < ApplicationRecord
  include UUIDHelper
  attr_accessor :skip_callback

  belongs_to :company
  belongs_to :import_job
  belongs_to :status, class_name: 'ImportRecordStatus'
  belongs_to :document, polymorphic: true, optional: true

  serialize :record_data, JSON
  serialize :processed_data, JSON

  scope :with_status_id, ->(status_id) {
    where status_id: status_id
  }

  after_save :run_computations, unless: :skip_callback

  # This method calculates the item related values for the first time
  # This happens in FE automatically in normal cases but in imports this has to be done manually
  def run_computations
    return unless self.import_job[:options]["route"] == "forms.invoices"
    computed_items = []
    return if self.processed_data["items"].nil?
    self.processed_data["items"].each do |item|
      item_record = Item.find(item['inventory_line_item_id'].to_i)
      next if item_record.nil?

      item_gross_amount = (item['rate'] * item['quantity']).round(2)
      discount = item['discount']
      discount_amount = self.processed_data['discount_type_id'] == 1 ? item_gross_amount * discount : discount
      item_taxable_amount = item_gross_amount.to_f - discount_amount.to_f
      tax_percentage = item_record.tax_rate&.rate.to_f
      computed_items << {
        'item_number': item_record.item_number,
        'unit_of_measurement': item_record.unit_of_measurement,
        'item_gross_amount': item_gross_amount.to_f,
        'item_discount_amount': discount_amount.to_f,
        'item_taxable_amount': item_taxable_amount.to_f,
        'tax_percentage': tax_percentage.to_f,
        'item_tax_amount': ((item_taxable_amount * tax_percentage)/100).to_f,
        'item_tds_amount': (item['tds_applicable'] ? (processed_data['tds_percentage']*item_taxable_amount)/100 : 0).to_f,
        'item_net_amount': (processed_data['rcm_enabled'] ? item_taxable_amount : item_taxable_amount + item_tax_amount).to_f,
        'item_billable_amount': item_taxable_amount.to_f
      }.stringify_keys.merge(item){|_key, old_value, new_value| new_value.present? ? new_value : old_value}
    end
    self.processed_data['items'] = computed_items
    self.skip_callback = true
    self.save
  end

  def data_with_attachments
    json_data = record_data

    import_job.meta_data["attachment_keys"]&.each do |key, values|
      nodes = [json_data]
      nodes = json_data[key] unless key == 'main'
      nodes&.each do |node|
        values.each do |value|
          atts = import_job.import_job_attachments.where(identifier: "#{node['_ref']}_#{value}")

          if node[value].present?
            atts = atts.or(import_job.import_job_attachments.where(identifier: node[value].split("\n")))
          end

          node["#{value}_attachments_data"] = atts&.as_json(compact: true)

        end
      end
    end

    json_data
  end

  def as_json(options = {})
    {
      id: id,
      status: status&.name,
      message: message,
      record_data: data_with_attachments,
      processed_data: bool_corrected_processed_data,
    }
  end

  def update_status(success, message, internal_message, error_trace)
    if success
      self.status_id = ImportRecordStatus.id_for(:success)
    else
      self.status_id = ImportRecordStatus.id_for(:failed)
    end
    self.message = message
    self.internal_message = internal_message
    self.error_trace = error_trace
    self.save!
  end

  def bool_corrected_processed_data
    json_data = processed_data
    if json_data != nil
      json_data.keys.each do |k|
        if json_data[k] != nil && json_data[k].kind_of?(Array)
          json_data[k].each do |p|
            if p != nil
              p.keys.each do |k1|
                p[k1] = p[k1] == 'TRUE' if %w[TRUE FALSE].include? p[k1]
              end
            end
          end
        else
          json_data[k] = json_data[k] == 'TRUE' if json_data[k] != nil && %w[TRUE FALSE].include?(json_data[k])
        end
      end
    end
    json_data
  end

end
