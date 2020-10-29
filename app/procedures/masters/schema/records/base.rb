class Masters::Schema::Records::Base < Transactions::API

  def self.RecordModelClass()
    Transactions::Task.build id: "build_record_model_class" do |context, flow_options, circuit_options|
      current_user = context[:current_user]
      params = context[:params]
      key_path = context[:key_path] || :master_key
      master_key = params[key_path] || context[key_path]

      # master_key can be fetched from the route with the format masters.<master_key>
      context[:master_schema] = MasterSchema.find_by(company_id: current_user.company_id, master_key: master_key)
      unless context[:master_schema].present?
        next on_error context, :base, 'master not found'
      end

      context[:model_class] = context[:params][:model_class] = context[:master_schema].model

      unless context[:model_class].present?
        next on_error context, :base, 'master not found'
      end

      true
    end
  end

  def self.RecordModel(type = :nil)
    Transactions::Task.build id: "build_record_model" do |context, flow_options, circuit_options|
      current_user = context[:current_user]
      params = context[:params]
      key_path = context[:key_path] || :master_key
      master_key = params[key_path] || context[key_path]

      # master_key can be fetched from the route with the format masters.<master_key>
      context[:master_schema] = MasterSchema.find_by(company_id: current_user.company_id, master_key: master_key)
      unless context[:master_schema].present?
        next on_error context, :base, 'master not found'
      end

      id = params[:id]
      context[:model_class] = scoped_model = context[:master_schema].model

      if scoped_model == MasterRecord
        scoped_model = scoped_model.where(master_schema_id: context[:master_schema].id)
      end

      case type
      when :find_or_new
        # if nil, find, new if not found
        context[:model] = scoped_model.find_or_initialize_by(id: id)
        context[:model] = scoped_model.new if context[:model].nil?
      when :new
        context[:model] = scoped_model.new
      when :find
        context[:model] = scoped_model.send(:find_by_id, id)
      else
        raise "Invalid type :#{type}"
      end

      unless context[:model].present?
        next on_error context, :base, 'record not found'
      end

      if context[:model].class == MasterRecord
        context[:model].master_schema_id ||= context[:master_schema].id
      end

      true
    end
  end

end