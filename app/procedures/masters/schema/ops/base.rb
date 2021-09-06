class Masters::Schema::Ops::Base < Transactions::API

  def self.FindMasterSchema(key_path: :id)
    Transactions::Task.build id: "find_master_schema" do |context, flow_options, circuit_options|
      # current_user:, params:, key_path: :id,
      current_user = context[:current_user]
      params = context[:params]
      master_key = params[key_path] || context[key_path]
      return on_error context, :base, 'master not found' if master_key.blank?

      context[:model] = MasterSchema.find_by(company_id: current_user.company_id, master_key: master_key)
      unless context[:model].present?
        return on_error context, :base, 'master not found'
      end

      true
    end
  end

end