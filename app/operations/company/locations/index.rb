class Company::Locations::Index < Company::Locations::Base

  attr_accessor :locations ,:policy_location_filter_mapping, :current_application

  class Company::Locations::Index::LocationsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :locations, :policy_location_filter_mapping, :all_locations

    def init
      self.locations = params[:locations]
      self.policy_location_filter_mapping = params[:policy_location_filter_mapping]

      # used in vp organization account
      self.all_locations = self.locations
    end
  end

  def user_model
    [User, AdminUser]
  end

  def init
    self.current_application = params[:current_app] || current_app
  end

  def validate
    if user.company.blank?
      add_message :error, "Company not found"
    end
  end

  def process
    user_role_id = params[:filter_role_id]
    self.locations = user.company.locations.non_deleted
    # Locations which are mapped to policies to which user is part of
    unless user.class.name =='AdminUser'
      if user_role_id.present?
        location_ids = user.company.policies.joins(:policy_user_roles).where('policy_user_roles.user_id = ? AND policy_user_roles.user_role_id IN (?)', user.id, user_role_id)&.joins(:policy_location_mappings).with_application(current_application)&.exclude_deleted&.pluck('policy_location_mappings.location_id')
      else
        location_ids = user.company.policies.joins(:policy_user_roles).where('policy_user_roles.user_id = ?', user.id)&.joins(:policy_location_mappings).with_application(current_application)&.exclude_deleted&.pluck('policy_location_mappings.location_id')
      end
      location_parent_id = [user.company&.locations&.non_deleted&.where(id: location_ids)&.last&.parent&.id] rescue []
      self.policy_location_filter_mapping = user.company&.locations&.non_deleted&.where(id: location_ids + location_parent_id) unless location_ids.blank?
    end
  end

  def success
    params[:locations] = self.locations
    params[:policy_location_filter_mapping] = self.policy_location_filter_mapping
    Company::Locations::Index::LocationsPresenter.new(user, params, messages)
  end
end