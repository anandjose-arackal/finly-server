class Masters::Schema::Records::Ops::BulkUpdate < Masters::Schema::Records::Base
  #  Todo - will take this up based on the library selected
  schema do
    params do
      required(:master_key).filled
      required(:records).array do
        hash do
          optional(:id)
          # Varies from master to master
        end
      end
    end
  end

  step RecordModelClass()
  # Create an empty hash used for the purpose of caching
  pass :init_references
  # Validate all records to be updated as valid records
  step :validate_record_update
  # Validate all self referencing associations
  step :validate_parent_references

  def init_references(context, **)
    context[:record_references] = {}
  end

  # Validate all records to be updated as valid records
  def validate_record_update(context, params:, model_class:, master_schema:, **)
    persisted_record_ids = []
    persisted_records = {}
    params[:records].each do |rec|
      persisted_record_ids << rec[:id] if rec[:id].present?
    end
    model_class.where(id: persisted_record_ids).each do |rec|
      persisted_records[rec.id] = rec
    end

    invalid_record_ids = persisted_record_ids - persisted_records.keys
    if invalid_record_ids.present?
      params[:records].each do |rec|
        next if rec[:id].blank?
        next unless invalid_record_ids.include?(rec[:id])

        rec[:status] = "Invalid"
        rec[:message] = "Record not found"
        context[:has_error] ||= true
      end
    end
  end

  def validate_parent_references(context, params:, model_class:, master_schema:, **)

  end
end