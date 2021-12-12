class Masters::Locations::Resolver < Resolver::API

  entity BranchLocation

  def load(params)
       
    if params.dig(:assignments, :form) == true
      doc_user = params[:document_type]&.classify&.constantize.find(params[:document_id]).created_by rescue user
      locations = Company::Locations::Index.(doc_user, params).policy_location_filter_mapping&.leaves

      return BranchLocation.none if locations.nil?
      locations
    else
      if user.admin?
        user.company.locations
      else
        policies = user.policies
        policies = policies.with_application(app) if app.present?
        policy_ids = policies.pluck(:id)
        location_ids = [user.location_id]
        location_ids += PolicyLocationMapping.where(policy_id: policy_ids).pluck(:location_id)
        BranchLocation.where(id: location_ids)
      end
    end
  end

end
