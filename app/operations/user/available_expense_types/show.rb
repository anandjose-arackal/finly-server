class User::AvailableExpenseTypes::Show < User::Base

  attr_accessor :distance_config, :time_config, :per_diem_config,
                :policy, :report, :company, :custom_fields_config,
                :cash_on_hand, :em_tax_tracking, :tds_slabs,
                :cash_pocket

  class User::AvailableExpenseTypes::Show::ExpenseTypesPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :distance_config, :time_config, :per_diem_config, :categories, :custom_fields_config, :currencies, :cash_on_hand,
                  :em_tax_tracking, :tds_slabs, :cash_and_credit_pockets, :custom_currency_conversion

    def init
      self.distance_config = params[:distance_config]
      self.time_config = params[:time_config]
      self.per_diem_config = params[:per_diem_config]
      self.categories = params[:categories]
      self.custom_fields_config = params[:custom_fields_config]
      self.cash_on_hand = params[:cash_on_hand]
      self.currencies = Currency.all
      self.em_tax_tracking = params[:em_tax_tracking]
      self.tds_slabs = params[:tds_slabs]
      self.cash_and_credit_pockets = user.user_pockets.non_bank_card_transfer_pockets.active
      self.custom_currency_conversion = user.company.feature_subscription.custom_currency_conversion
    end

  end

  def authorized_user_types
    [:employee, :vendor_payments_admin]
  end

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, 'Invalid parameters'
    end
  end

  def init
    self.company = user.company
    self.report = user.reports.find_by(id: params[:report_id])
    self.policy = report.policy if report.present?
    self.cash_pocket = user.user_pockets.cash_pockets_only.first
    self.cash_on_hand = AccountManager::CashPockets::CashPocketsAdapter.new(self.cash_pocket).balance(display_balance: true)
    self.em_tax_tracking = user.company.feature_subscription.em_tax_tracking
    if self.em_tax_tracking
      op_tds_slabs_index = TdsSlabs::Index.(user, params)
      self.tds_slabs = op_tds_slabs_index.tds_slabs
    end
  end

  def validate
    if params[:report_id].present? && report.nil?
      add_message :error, 'Invalid report ID'
      return
    end
  end

  def authorize

  end

  def process
    if report
      if policy
        self.distance_config = {
            enabled: policy.distance_expense_enabled?,
            vehicle_rates: policy.vehicle_rates,
            default_category_id: policy.distance_expense_config.default_category_id
        }
        self.time_config = {enabled: policy.time_expense_enabled?,
                            rate: policy.time_expense_config.rate,
                            default_category_id: policy.time_expense_config.default_category_id
        }
        self.per_diem_config = {enabled: policy.per_diem_expense_enabled?}
        if per_diem_config
          if policy.per_diems.active.empty?
            self.per_diem_config = {enabled: false}
            self.per_diem_config[:per_diems] = []
          else
            per_diem_config[:per_diems] = []
            policy.per_diems.active.each do |per_diem|
              currency = per_diem.configurable.base_currency
              per_diem_config[:per_diems] << {name: "#{per_diem.configurable.name} - #{per_diem.name}",
                                              id: per_diem.id,
                                              rate: per_diem.rate_value,
                                              currency: currency
              }
            end
          end
        end
      end
      # checks whether distance, time and per diem expenses are enabled for this particular report
    else
      # checks whether for this particular user the distance, time and per diem expenses are enabled
      self.distance_config = {enabled: user.distance_expense_enabled?, vehicle_rates: []}
      policies = retrieve_policies
      policies.each do |policy|
        policy.vehicle_rates.each do |vehicle_rate|
        self.distance_config[:vehicle_rates] << vehicle_rate.as_json
        end
      end
      self.time_config = {enabled: user.time_expense_enabled?}
      self.per_diem_config = {enabled: user.per_diem_expense_enabled?}
      if per_diem_config
        if user.per_diems_list.empty?
          self.per_diem_config = {enabled: false}
          self.per_diem_config[:per_diems] = []
        else
          per_diem_config[:per_diems] = []
          user.per_diems_list.each do |per_diem|
            if user.enforce_policy_enabled? && per_diem.configurable.default
              next
            end
            currency = per_diem.configurable.base_currency
            per_diem_config[:per_diems] << {name: "#{per_diem.configurable.name} - #{per_diem.name}",
                                            id: per_diem.id,
                                            rate: per_diem.rate_value,
                                            currency: currency
            }
          end
        end
      end
    end

    load_custom_fields_config
  end

  def load_custom_fields_config
    configurations = user.company.field_configurations.exclude_deleted.root_fields.order_created_at_desc
    self.custom_fields_config = {}
    self.custom_fields_config[:manual_expense] = configurations.with_parent_type(FieldParentType.id_for(:manual_expense))
    self.custom_fields_config[:card_expense] = configurations.with_parent_type(FieldParentType.id_for(:card_expense))
    self.custom_fields_config[:distance_expense] = configurations.with_parent_type(FieldParentType.id_for(:distance_expense)) if distance_config[:enabled]
    self.custom_fields_config[:time_expense] = configurations.with_parent_type(FieldParentType.id_for(:time_expense)) if time_config[:enabled]
    self.custom_fields_config[:per_diem_expense] = configurations.with_parent_type(FieldParentType.id_for(:per_diem_expense)) if per_diem_config[:enabled]
  end

  def retrieve_policies
    if user.enforce_policy_enabled?
      return user.policies.with_application(current_app).non_default.non_deleted
    end
    user.policies.with_application(current_app).non_deleted
  end

  def success
    params[:distance_config] = distance_config
    params[:time_config] = time_config
    params[:per_diem_config] = per_diem_config
    params[:custom_fields_config] = self.custom_fields_config
    params[:categories] = self.user.company.categories.expense_management_only.active
    params[:cash_on_hand] = self.cash_on_hand
    params[:em_tax_tracking] = self.em_tax_tracking
    params[:tds_slabs] = self.tds_slabs
    User::AvailableExpenseTypes::Show::ExpenseTypesPresenter.new(user, params, messages)
  end
end