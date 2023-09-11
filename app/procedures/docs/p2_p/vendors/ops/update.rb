class TransactionStep

  def self.call(_ctx, *)
    ActiveRecord::Base.transaction { yield }&.first
  end
end

class RollbackStep

  def self.call(*)
    raise ActiveRecord::Rollback
  end
end

class Docs::P2P::Vendors::Ops::Update < Transactions::API

  step Form(route: 'vendors')
  step Model(YesBankVendor, :find_by)
  step Policy::Pundit(Masters::Vendors::Policy, :update?)
  step Wrap(TransactionStep){
    step Forms::Contracts::Build()
    step Contract::Validate()
    step :validate_unique_gst
    step Contract::Persist()
    fail RollbackStep
  }
  step Transactions::Messages::SuccessMessage('Updated')

  def validate_unique_gst(options, params, **)
    return true if params[:params][:gstin_locations].nil?
    locations = params[:params][:gstin_locations].reject{|location| location["_destroy"]}
    unless locations.pluck(:gstin).uniq.size == locations.size
      add_message options, :error, :base, "Locations have duplicate gstin numbers."
      return false
    end
    return true
  end
end