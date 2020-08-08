class Masters::Schema::Records::Base < Transactions::API

  def self.FindMasterSchema()
    Transactions::Task.build id: "find_master_schema" do |context, current_user:, params:, key_path: :id, **|
      master_key = params[key_path] || context[key_path]
      return on_error context, :base, 'master not found' if master_key.blank?

      context[:model] = MasterSchema.find_by(company_id: current_user.company_id, master_key: master_key)
      unless context[:model].present?
        return on_error context, :base, 'master not found'
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

      case type
      when :find_or_new
        # if nil, find, new if not found
        context[:model] = context[:master_schema].record_model&.send(type, id)
        context[:model] = context[:master_schema].record_model&.new if context[:model].nil?
      when :new
        context[:model] = context[:master_schema].record_model&.new
      when :find
        context[:model] = context[:master_schema].record_model&.send(type, id)
      else
        raise "Invalid type :#{type}"
      end

      unless context[:model].present?
        next on_error context, :base, 'master not found'
      end

      true
    end
  end

end