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
      if QueryOptBranchDeptNonForm.new(user).enabled?
        self.policy_location_filter_mapping = faster_location_filter_mapping user_role_id
      else
        self.policy_location_filter_mapping = slower_old_location_filter_mapping user_role_id
      end
    end
  end

  def slower_old_location_filter_mapping(user_role_id)
    # Locations which are mapped to policies to which user is part of
    if user_role_id.present?
      location_ids = user.company.policies.joins(:policy_user_roles).where('policy_user_roles.user_id = ? AND policy_user_roles.user_role_id IN (?)', user.id, user_role_id)&.joins(:policy_location_mappings).with_application(current_application)&.exclude_deleted&.pluck('policy_location_mappings.location_id')
    else
      location_ids = user.company.policies.joins(:policy_user_roles).where('policy_user_roles.user_id = ?', user.id)&.joins(:policy_location_mappings).with_application(current_application)&.exclude_deleted&.pluck('policy_location_mappings.location_id')
    end
    location_parent_id = [user.company&.locations&.non_deleted&.where(id: location_ids)&.last&.parent&.id] rescue []

    user.company&.locations&.non_deleted&.where(id: location_ids + location_parent_id) unless location_ids.blank?

  end

  def faster_location_filter_mapping(user_role_id)
    locations_for_filter_mapping = user.company.locations&.
      select("DISTINCT(branch_locations.id), branch_locations.*")&.
      joins(policy_location_mappings: { policy: :policy_user_roles })&.
      merge(Policy.with_application(current_application))&.
      merge(Policy.exclude_deleted)&.
      merge(PolicyUserRole.where(company_id: company.id, user_id: user.id)).
      reorder(nil)&.
      non_deleted&.
      order('branch_locations.id': :asc)

    if user_role_id.present?
      locations_for_filter_mapping = locations_for_filter_mapping.
        where('policy_user_roles.user_id = ? AND policy_user_roles.user_role_id IN (?)', user.id, user_role_id)
    else
      locations_for_filter_mapping = locations_for_filter_mapping.
        where('policy_user_roles.user_id = ?', user.id)
    end
    # locations_for_filter_mapping_arr = locations_for_filter_mapping.to_a
    #
    # parent_loc = locations_for_filter_mapping_arr&.last&.parent
    # locations_for_filter_mapping_arr << parent_loc if parent_loc.present?
    locations_for_filter_mapping
  end

  def success
    params[:locations] = self.locations
    params[:policy_location_filter_mapping] = self.policy_location_filter_mapping
    Company::Locations::Index::LocationsPresenter.new(user, params, messages)
  end
end