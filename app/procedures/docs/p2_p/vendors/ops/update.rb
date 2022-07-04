class Docs::P2P::Vendors::Ops::Update < Transactions::API

  step Form(route: 'vendors')
  step Model(YesBankVendor, :find_by)
  step Policy::Pundit(Masters::Vendors::Policy, :update?)
  step Forms::Contracts::Build()
  step Contract::Validate()
  step :validate_unique_gst
  step Contract::Persist()
  step Transactions::Messages::SuccessMessage('Updated')

  def validate_unique_gst(options, params, **)
    locations = params[:params][:gstin_locations]
    unless locations.pluck(:gstin).uniq.size == locations.size
      add_message options, :error, :base, "Locations have duplicate gstin numbers."
      return false
    end
    return true
  end
end