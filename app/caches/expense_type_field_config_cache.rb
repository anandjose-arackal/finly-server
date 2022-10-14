class ExpenseTypeFieldConfigCache < BaseApplicationCache

  def enabled?
    EmFieldConfigCacheToggle.new(@current_user).enabled?
  end

  def cache_instance_id
    "ONLY"
  end

  def expires_in
    nil
  end

  def load_config_data
    configurations = @company.field_configurations.
      includes(:field_type, :drop_down_items).
      exclude_deleted.root_fields.order_created_at_desc.
      with_parent_type(FieldParentType.expense_ids).
      select('field_configurations.*, field_parent_mappings.field_parent_type_id as field_parent_type_id')

    custom_fields_config = {
      manual_expense: [],
      card_expense: [],
      distance_expense: [],
      time_expense: [],
      per_diem_expense: []
    }

    configurations.each do |config|
      case config.field_parent_type_id
      when FieldParentType.id_for(:manual_expense)
        custom_fields_config[:manual_expense] << config
      when FieldParentType.id_for(:card_expense)
        custom_fields_config[:card_expense] << config
      when FieldParentType.id_for(:distance_expense)
        custom_fields_config[:distance_expense] << config
      when FieldParentType.id_for(:time_expense)
        custom_fields_config[:time_expense] << config
      when FieldParentType.id_for(:per_diem_expense)
        custom_fields_config[:per_diem_expense] << config
      end
    end

    custom_fields_config.to_json
  end

  def eager_load_data
    current_cached_data = read
    unless enabled? && current_cached_data.nil?
      return
    end

    write_success = write do
      current_cached_data = load_config_data
      current_cached_data
    end

    if write_success
      current_cached_data
    end
  end

  def refresh
    unless enabled?
      return
    end
    invalidate
    eager_load_data
  end

  def custom_fields_config_json
    current_cached_data = read
    unless enabled?
      return load_config_data
    end

    if current_cached_data.nil?
      return eager_load_data
    end

    current_cached_data
  end
end
