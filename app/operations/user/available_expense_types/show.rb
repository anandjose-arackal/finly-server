class User::AvailableExpenseTypes::Show < User::Base

  attr_accessor :distance_config, :time_config, :per_diem_config, :policy, :report, :company

  class User::AvailableExpenseTypes::Show::ExpenseTypesPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :distance_config, :time_config, :per_diem_config, :categories

    def init
      self.distance_config = params[:distance_config]
      self.time_config = params[:time_config]
      self.per_diem_config = params[:per_diem_config]
      self.categories = params[:categories]
    end
  end

  def authorized_user_types
    [:employee]
  end

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    self.company = user.company
    self.report = user.reports.find_by(id: params[:report_id])
    self.policy = report.policy if report.present?
  end

  def validate
    if params[:report_id].present? && report.nil?
      add_message :error, "Invalid report ID"
      return
    end
  end

  def authorize

  end

  def process
    if report
      if policy
        self.distance_config = {enabled: policy.distance_expense_enabled?,
                                rate: policy.distance_expense_config.rate,
                                default_category_id: policy.distance_expense_config.default_category_id
                                }
        self.time_config = {enabled: policy.time_expense_enabled?,
                            rate: policy.time_expense_config.rate,
                            default_category_id: policy.time_expense_config.default_category_id
                            }
        self.per_diem_config = {enabled: policy.per_diem_expense_enabled?}
        if per_diem_config
          if policy.per_diems.empty?
            self.per_diem_config = {enabled: false}
            self.per_diem_config[:per_diems] = []
          else
            per_diem_config[:per_diems] = []
            policy.per_diems.each do |per_diem|
              per_diem_config[:per_diems] << {name: "#{per_diem.configurable.name} - #{per_diem.name}",
                                              id: per_diem.id,
                                              rate: per_diem.rate_value
              }
            end
          end
        end
      else
        self.distance_config = {enabled: company.distance_expense_enabled?,
                                rate: company.distance_expense_config.rate,
                                default_category_id: company.distance_expense_config.default_category_id
                                }
        self.time_config = {enabled: company.time_expense_enabled?,
                            rate: company.time_expense_config.rate,
                            default_category_id: company.time_expense_config.default_category_id
                           }
        self.per_diem_config = {enabled: company.per_diem_expense_enabled?}
        if per_diem_config
          if company.per_diems.empty?
            self.per_diem_config = {enabled: false}
            self.per_diem_config[:per_diems] = []
          else
            per_diem_config[:per_diems] = []
            company.per_diems.each do |per_diem|
              per_diem_config[:per_diems] << {name: "#{per_diem.configurable.name} - #{per_diem.name}",
                                              id: per_diem.id,
                                              rate: per_diem.rate_value
              }
            end
          end
        end
      end
      # checks whether distance, time and per diem expenses are enabled for this particular report
    else
      # checks whether for this particular user the distance, time and per diem expenses are enabled
      self.distance_config = {enabled: user.distance_expense_enabled?}
      self.time_config = {enabled: user.time_expense_enabled?}
      self.per_diem_config = {enabled: user.per_diem_expense_enabled?}
      if per_diem_config
        if user.per_diems_list.empty?
          self.per_diem_config = {enabled: false}
          self.per_diem_config[:per_diems] = []
        else
          per_diem_config[:per_diems] = []
          user.per_diems_list.each do |per_diem|
            per_diem_config[:per_diems] << {name: "#{per_diem.configurable.name} - #{per_diem.name}",
                                            id: per_diem.id,
                                            rate: per_diem.rate_value
            }
          end
        end
      end
    end



  end

  def success
    params[:distance_config] = distance_config
    params[:time_config] = time_config
    params[:per_diem_config] = per_diem_config
    User::AvailableExpenseTypes::Show::ExpenseTypesPresenter.new(user, params, messages)
  end
end