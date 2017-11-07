# {
#     source_account_type: 'finly_money',
#     payment_type: 'bank_transfer',
#     payment_mode: 'imps',
#     scheduled_at: '14-10-2017',
#     mappings: {
#         '1': {
#             report_ids: [],
#             processor_accountable_id: '',
#             processor_accountable_type: '',
#             amount: {
#                 value: 100,
#                 currency_id: 1
#             }
#         }
#     }
# }
class Settlement::SReport::Processing::Create < Settlement::SReport::Processing::Base
  attr_accessor :processor_params, :report_processor_group, :scheduled, :payment_request

  def authorized_user_types
    [:admin, :finance_manager]
  end

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params&.dig(:payment_type).blank?
      add_message :error, 'Invalid Payment Type'
      return
    end
  end

  def init
    role_id = admin_view? ? UserRole.id_for(:admin) : UserRole.id_for(:finance_manager)
    self.report_processor_group = current_company.report_processor_groups.new({
                                                                                  created_by_user: user,
                                                                                  created_by_user_role_id: role_id,
                                                                                  scheduled_at: params[:scheduled_at],
                                                                                  payment_type: params[:payment_type],
                                                                                  payment_mode: params[:payment_mode]
                                                                              })
    if params[:scheduled_at].present? and Date.parse(params[:scheduled_at]) > Date.today
      self.report_processor_group.status_id = ReportProcessorGroupStatus.id_for(:scheduled)
      self.scheduled = true
    else
      self.report_processor_group.status_id = ReportProcessorGroupStatus.id_for(:pending)
      self.scheduled = false
    end
    set_source_account
    set_receiving_accounts
    set_payment_request
  end

  def validate
    unless self.report_processor_group.valid?
      add_message :error, self.report_processor_group.errors.full_messages
      return
    end
    validator = AccountManager::Payments::PaymentValidator.(self.report_processor_group.payment_order)
    unless validator.success?
      add_message :error, validator.messages[:error]
      return
    end
  end

  def process
    self.report_processor_group.save
    if self.report_processor_group.process_via_finly?
      AccountManager::Payments::PaymentProcessor.(user, payment_request: payment_request)
    end
  end

  protected

  def set_source_account
    unless ['company_credits', 'finly_money'].include?(params[:source_account_type])
      add_message :error, 'Invalid Source Account Type'
      return
    end
    case params&.dig(:payment_type)
      when 'bank_transfer'
        case params[:source_account_type]
          when 'company_credits'
            self.report_processor_group.source_account = current_company.yes_bank_company_account
          when 'finly_money'
            self.report_processor_group.source_account = user.bank_wallet
        end
      when 'reimbursement_card'
        case params[:source_account_type]
          when 'company_credits'
            self.report_processor_group.source_account = current_company.itz_cash_company_account
          when 'finly_money'
            self.report_processor_group.source_account = user.user_wallet
        end
      when 'outside_finly', 'payment_file'
        # Nothing to do here as receiving account is nil
      else
        add_message :error, 'Invalid Source Account Type'
        return
    end
  end

  def set_receiving_accounts
    users_presenter = User::Index.(user, params)
    unless users_presenter.success?
      add_message :error, users_presenter.messages[:error]
      return
    end
    mappings = params&.dig(:mappings)
    user_ids = mappings.keys
    if user_ids.blank? or user_ids.size == 0
      add_message :error, 'Users not found'
      return
    end

    users = users_presenter.team.include_reimbursable_accounts.with_id(user_ids)
    unless users.count == user_ids.size
      add_message :error, 'Error loading configuration'
      return
    end

    total = 0
    currency_id = nil

    users&.each do |user|
      config = params&.dig(:mappings, user.id.to_s)

      processor_accountable_id = config[:processor_accountable_id]
      processor_accountable_type = config[:processor_accountable_type]
      processor_accountable = nil

      case params&.dig(:payment_type)
        when 'bank_transfer', 'payment_file'
          unless processor_accountable_type == BankAccount.name
            add_message :error, 'Funds can only be transferred to Bank Account in this mode'
            return
          end
          processor_accountable = user.bank_accounts.find_by_id(processor_accountable_id)
          if processor_accountable.blank?
            add_message :error, 'Bank Account not found'
            return
          end
        when 'reimbursement_card'
          unless processor_accountable_type == Card.name
            add_message :error, 'Funds can only be transferred to Bank Account in this mode'
            return
          end
          processor_accountable = user.reimbursement_cards.find_by_id(processor_accountable_id)
          if processor_accountable.blank?
            add_message :error, 'Reimbursement Card not found'
            return
          end
        when 'outside_finly'
          # Nothing to do here as receiving account is nil
      end

      report_ids = config[:report_ids]
      reports = user.reports.approved.with_id(report_ids)
      unless report_ids.size == reports.size
        add_message :error, 'Error loading configuration'
        return
      end

      unless report_ids.size > 0
        add_message :error, "No reports found for #{user.name}"
        return
      end

      total += config&.dig(:amount, :value)&.to_d
      currency_id = config&.dig(:amount, :currency_id)

      if config&.dig(:amount, :value).blank?
        add_message :error, 'Amount cannot be empty'
        return
      elsif config&.dig(:amount, :value)&.to_d <= 0
        add_message :error, 'Amount has to be greater than or equal to 0'
        return
      end
      mapping_status = ReportProcessorGroupStatus.id_for(:pending)
      self.report_processor_group.mappings.build({
                                                     user: user,
                                                     processor_accountable: processor_accountable,
                                                     reports: reports,
                                                     amount_attributes: {
                                                         value: config&.dig(:amount, :value),
                                                         currency_id: config&.dig(:amount, :currency_id)
                                                     },
                                                     status_id: mapping_status
                                                 })
    end

    self.report_processor_group.total_amount = Amount.new(value: total, currency_id: currency_id)
  end

  def set_payment_request
    return unless self.report_processor_group.process_via_finly?
    receiving_account_class = params&.dig(:payment_type) == 'bank_transfer' ? BankAccount.name : Card.name
    post_operation = 'Settlement::SReport::Processing::PostOperation'
    post_operation_payload = {}
    self.payment_request = ::PaymentRequest.(user, self.report_processor_group.source_account,
        receiving_account_class, :credit, :reimbursement,
        background: true, scheduled_at: self.report_processor_group.scheduled_at,
        post_operation: post_operation, post_operation_payload: post_operation_payload)
    self.report_processor_group.payment_order = self.payment_request.payment_order
    self.report_processor_group.mappings.each do |mapping|
      payment_item = PaymentRequest::PaymentItem.(mapping.user, mapping.processor_accountable, mapping.amount.value)
      self.payment_request.add_payment_item(payment_item)
      mapping.payment = payment_item.payment
    end
  end

end