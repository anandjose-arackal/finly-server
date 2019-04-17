class Company::Locations::Index < Company::Locations::Base

  attr_accessor :locations ,:policy_location_filter_mapping

  class Company::Locations::Index::LocationsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :locations, :policy_location_filter_mapping

    def init
      self.locations = params[:locations]
      self.policy_location_filter_mapping = params[:policy_location_filter_mapping]
    end
  end

  def validate
    if self.company.blank?
      add_message :error, "Company not found"
    end
  end

  def process
    self.locations = self.company.locations
    # Locations which are mapped to policies to which user is part of
    location_ids = user.company.policies.joins(:policy_user_roles).where('policy_user_roles.user_id = ?', user.id)&.joins(:policy_location_mappings).with_application(current_app)&.exclude_deleted&.pluck('policy_location_mappings.location_id')
    location_parent_id = [user.company&.locations&.where(id: location_ids)&.last&.parent&.id] rescue []
    self.policy_location_filter_mapping = user.company&.locations&.where(id: location_ids + location_parent_id) unless location_ids.blank?
  end

  def success
    params[:locations] = self.locations
    params[:policy_location_filter_mapping] = self.policy_location_filter_mapping
    Company::Locations::Index::LocationsPresenter.new(user, params, messages)
  end
end