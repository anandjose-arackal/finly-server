# Operation that showcases the different configurations of the types of expenses
# Input parameters
# parent_type: 'company' pr 'policy'
# parent_id: id of the policy that's being shown
#
#
# Response params:
# distance_config: { enabled: true or false
#                    rate_per_km: conversion rate for distance
#                 }
# time_config: { enabled: true or false
#                rate_per_hour: conversion rate for time
#               }
# per_diem_config:{ enabled: true or false
                #   per_diems: [{
                #             name:
                #             rate:
                #            },
                #            {
                #             name:
                #             rate:
                #            },
                #            .
                #            .
                #            .]
                # }


class ExpenseTypes::Show < ExpenseTypes::Base

  attr_accessor :parent, :distance_config, :time_config, :per_diem_config

  def authorized_user_types
    [:company_admin, :policy_admin]
  end

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    case params[:parent_type]
      when 'company'
        self.parent = user.company
      when 'policy'
        policies = Policy::Index.(user, {view: 'policy_admin'}).policies rescue []
        self.parent = policies.find_from_id(params[:parent_id]) rescue nil
      else
        self.parent = nil
    end
    self.distance_config = self.time_config = self.per_diem_config = {}
  end

  def authorize
    unless parent
      raise_unauthorized_exception
    end
  end

  def process
    if parent.distance_expense_config.enabled
      self.distance_config = {enabled: true,
                              rate_per_km: parent.distance_expense_config.rate_per_km}
    else
      self.distance_config = {enabled: false,
                              rate_per_km: parent.distance_expense_config.rate_per_km}
    end
    if parent.time_expense_config
      self.time_config = {enabled: true,
                          rate_per_hour: parent.time_expense_config.rate_per_hour}
    else
      self.time_config = {enabled: false,
                          rate_per_hour: parent.time_expense_config.rate_per_hour}
    end
    if parent.per_diem_expense_config.enabled
      self.per_diem_config = {enabled: true}
      parent.per_diems.each do |per_diem|
        self.per_diem_config[:per_diems] << {name: per_diem.name,
                                             rate: per_diem.rate_value
                                            }
      end
    else
      self.per_diem_config = {enabled: false}
      parent.per_diems.each do |per_diem|
        self.per_diem_config[:per_diems] << {name: per_diem.name,
                                             rate: per_diem.rate_value
        }
      end
    end
  end

  def success
    params[:distance_config] = self.distance_config
    params[:time_config] = self.time_config
    params[:per_diem_config] = self.per_diem_config
    ExpenseTypes::Show::ExpenseConfigurationPresenter.new(user, params, messages)
  end


  class ExpenseTypes::Show::ExpenseConfigurationPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :distance_config, :time_config, :per_diem_config

    def init
      self.distance_config = params[:distance_config]
      self.time_config = params[:time_config]
      self.per_diem_config = params[:per_diem_config]
    end
  end

end