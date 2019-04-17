class Procurements::FilterConfig < Procurements::Base
  attr_accessor :config, :status_tags, :po_statuses, :invoice_statuses, :locations, :departments, :sub_departments, :cost_centers

  def init
    self.status_tags = StatusTag.all
    self.po_statuses = PurchaseOrderStatus.all
    self.invoice_statuses = InwardInvoiceStatus.all
    self.locations = user.company.locations if user.vp_admin_or_auditor?
    # self.departments = user.company.departments.roots
    self.sub_departments = user.company.departments.only_sub_departments
    # self.sub_departments = user.company.dep_subdept_mapping
    self.cost_centers = user.company.cost_centers.with_application(current_app)
  end

  def process
    self.config = {}
    status_tags.each do |tag|
      self.config[tag.name] = tag.id
    end
    # Locations which are mapped to policies to which user is part of
    location_ids = user.company.policies.joins(:policy_user_roles).where('policy_user_roles.user_id = ?', user.id)&.joins(:policy_location_mappings).with_application(current_app)&.exclude_deleted&.pluck('policy_location_mappings.location_id')
    location_parent_id = [user.company&.locations&.where(id: location_ids)&.last&.parent&.id] unless location_ids.blank?
    self.locations = user.company&.locations&.where(id: location_ids + location_parent_id) unless location_ids.blank?
    # Departments which are mapped to policies to which user is part of
    department_ids = user.company.policies.joins(:policy_user_roles).where('policy_user_roles.user_id = ?', user.id).joins(:policy_department_mappings).with_application(current_app).exclude_deleted.pluck('policy_department_mappings.department_id')
    department_parent_id = [user.company.departments.where(id: department_ids)&.last&.parent&.id] unless location_ids.blank?
    self.departments = user.company.departments.where(id: department_ids + department_parent_id) unless department_ids.blank?
  end

  def success
    params[:config] = self.config
    params[:po_statuses] = self.po_statuses
    params[:invoice_statuses] = self.invoice_statuses
    params[:locations] = self.locations
    params[:departments] = self.departments
    params[:sub_departments] = self.sub_departments
    params[:cost_centers] = self.cost_centers
    Procurements::FilterConfig::ConfigPresenter.new(user, params, messages)
  end

  class Procurements::FilterConfig::ConfigPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :config, :po_statuses, :invoice_statuses, :locations, :departments, :sub_departments, :cost_centers, :sub_departments

    def init
      self.config = params[:config]
      self.po_statuses = params[:po_statuses]
      self.invoice_statuses = params[:invoice_statuses]
      self.locations = params[:locations]
      self.departments = params[:departments]
      self.sub_departments = params[:sub_departments]
      self.cost_centers = params[:cost_centers]
    end
  end
end