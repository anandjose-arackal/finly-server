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

  attr_accessor :parent, :distance_config, :time_config, :per_diem_config, :company

  def authorized_user_types
    [:company_admin, :policy_admin]
  end

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    self.company = user.company
    case params[:parent_type]
      when 'company'
        self.parent = company
      when 'policy'
        policies = Policy::Index.(user, view: 'admin').policies rescue []
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
                              rate_per_km: parent.distance_expense_config.rate_per_km,
                              default_category_id: parent.distance_expense_config.default_category_id
                             }
    else
      self.distance_config = {enabled: false,
                              rate_per_km: parent.distance_expense_config.rate_per_km,
                              default_category_id: parent.distance_expense_config.default_category_id
                              }
    end
    if parent.time_expense_config.enabled
      self.time_config = {enabled: true,
                          rate_per_hour: parent.time_expense_config.rate_per_hour,
                          default_category_id: parent.time_expense_config.default_category_id
                          }
    else
      self.time_config = {enabled: false,
                          rate_per_hour: parent.time_expense_config.rate_per_hour,
                          default_category_id: parent.time_expense_config.default_category_id
                          }
    end
    if parent.per_diem_expense_config.enabled
      self.per_diem_config = {enabled: true}
      self.per_diem_config[:per_diems] = []
      parent.per_diems.each do |per_diem|
        self.per_diem_config[:per_diems] << {name: per_diem.name,
                                             rate: per_diem.rate_value,
                                             id: per_diem.id
                                            }
      end
    else
      self.per_diem_config = {enabled: false}
      self.per_diem_config[:per_diems] = []
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
    params[:categories] = company.categories.active
    ExpenseTypes::Show::ExpenseConfigurationPresenter.new(user, params, messages)
  end


  class ExpenseTypes::Show::ExpenseConfigurationPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :distance_config, :time_config, :per_diem_config, :categories

    def init
      self.distance_config = params[:distance_config]
      self.time_config = params[:time_config]
      self.per_diem_config = params[:per_diem_config]
      self.categories = params[:categories]
    end
  end

end