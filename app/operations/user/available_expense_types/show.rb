class User::AvailableExpenseTypes::Show < User::Base

  attr_accessor :distance_config, :time_config, :per_diem_config

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

  end

  def validate

  end

  def authorize

  end

  def process
    self.distance_config = {enabled: user.distance_expense_enabled?}
    self.time_config = {enabled: user.time_expense_enabled?}
    self.per_diem_config = {enabled: user.per_diem_expense_enabled?}
    if per_diem_config
      if user.per_diems_list.empty?
        self.per_diem_config = {enabled: false}
      else
        per_diem_config[:per_diems] = []
        user.per_diems_list.each do |per_diem|
          per_diem_config[:per_diems] << {name: "#{per_diem.configurable.name} - #{per_diem.name}",
                                          id: per_diem.id
          }
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