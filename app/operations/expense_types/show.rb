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

  attr_accessor :policy, :distance_config, :time_config, :per_diem_config, :company

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
        policies = Policy::Index.(user, view: 'admin').policies rescue []
        self.policy = policies.find_by(id: params[:policy_id]) rescue nil
    self.distance_config = self.time_config = self.per_diem_config = {}
  end

  def authorize
    unless policy
      raise_unauthorized_exception
    end
  end

  def process
    if policy.distance_expense_config.enabled
      self.distance_config = {enabled: true,
                              rate_per_km: policy.distance_expense_config.rate_value,
                              default_category_id: policy.distance_expense_config.default_category_id,
                              default_category_name: policy.distance_expense_config.default_category_name

                             }
    else
      self.distance_config = {enabled: false,
                              rate_per_km: policy.distance_expense_config.rate_value,
                              default_category_id: policy.distance_expense_config.default_category_id,
                              default_category_name: policy.distance_expense_config.default_category_name
                              }
    end
    if policy.time_expense_config.enabled
      self.time_config = {enabled: true,
                          rate_per_hour: policy.time_expense_config.rate_value,
                          default_category_id: policy.time_expense_config.default_category_id,
                          default_category_name: policy.time_expense_config.default_category_name
                          }
    else
      self.time_config = {enabled: false,
                          rate_per_hour: policy.time_expense_config.rate_value,
                          default_category_id: policy.time_expense_config.default_category_id,
                          default_category_name: policy.time_expense_config.default_category_name

                          }
    end
    if policy.per_diem_expense_config.enabled
      self.per_diem_config = {enabled: true}
      self.per_diem_config[:per_diems] = []
      policy.per_diems.active.each do |per_diem|
        self.per_diem_config[:per_diems] << {name: per_diem.name,
                                             rate: per_diem.rate_value,
                                             id: per_diem.id
                                            }
      end
    else
      self.per_diem_config = {enabled: false}
      self.per_diem_config[:per_diems] = []
      policy.per_diems.active.each do |per_diem|
        self.per_diem_config[:per_diems] << {name: per_diem.name,
                                             rate: per_diem.rate_value,
                                             id: per_diem.id
        }
      end
    end
  end

  def success
    params[:distance_config] = self.distance_config
    params[:time_config] = self.time_config
    params[:per_diem_config] = self.per_diem_config
    params[:categories] = company.categories.active
    params[:base_currency] = policy.base_currency
    ExpenseTypes::Show::ExpenseConfigurationPresenter.new(user, params, messages)
  end


  class ExpenseTypes::Show::ExpenseConfigurationPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :distance_config, :time_config, :per_diem_config, :categories, :base_currency

    def init
      self.distance_config = params[:distance_config]
      self.time_config = params[:time_config]
      self.per_diem_config = params[:per_diem_config]
      self.categories = params[:categories]
      self.base_currency = params[:base_currency]
    end
  end

end