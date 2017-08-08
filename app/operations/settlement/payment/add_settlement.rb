# action to reimburse a bunch of reports in one shot
# params:
# report_ids: ids of the reports that are to be reimbursed.
# to_user_id or id: user whose reports are being settled
# payment:
# amount : value of the amount to be reimbursed - should match total of reports referenced via report_ids
# currency_id: currency of the reimbursement
# note: optional note to accompany payment
# date: date of the payment

class Settlement::Payment::AddSettlement < Settlement::Payment::Base
  include MathUtil
  attr_accessor :reports, :role, :report_total, :cash_deduction, :report_names, :reimbursement_card, :reimbursement_card_id,
                :reimbursement_amount, :cash_in_hand_deduction_amount, :outside_settlement_amount,
                :initiating_account, :initiating_account_type, :initiating_account_id, :reimbursement_type_id, :reimbursement_bank_account,
                :payment_request

  REIMBURSEMENT_TYPE = {:none => 1, :outside_finly => 2, :reimbursement_card => 3, :reimbursement_bank_account => 4}

  def authorized_user_types
    [:finance_manager, :admin]
  end

  def pre_validate
    super()
    return if has_errors?
    from_cash_in_hand = params[:payment][:from_cash_in_hand].to_f rescue 0
    from_outside_finly = params[:payment][:from_outside_finly].to_f rescue 0
    from_reimbursement_card = params[:payment][:from_reimburesement_card][:amount] rescue 0
    if from_cash_in_hand < 0
      add_message :error, 'Deduct Cash in Hand amount cannot be less than 0'
      return
    end
    if from_outside_finly < 0 or from_reimbursement_card < 0
      add_message :error, 'Reimbursement amount cannot cannot be less than 0'
      return
    end

    if params[:report_ids].blank?
      add_message :error, 'No reports to reimburse'
    end

    if params.dig(:payment, :reimbursement_type_id).blank?
      add_message :error, 'Reimbursement Type not found'
      return
    end

    case params.dig(:payment, :reimbursement_type_id)
      when REIMBURSEMENT_TYPE[:reimbursement_card], REIMBURSEMENT_TYPE[:reimbursement_bank_account]
        initiating_account_id = params&.dig(:payment, :initiating_account_id)&.to_sym
        initiating_account_type = params&.dig(:payment, :initiating_account_type)&.to_sym
        if initiating_account_type.blank? or (initiating_account_type == :card and initiating_account_id.blank?)
          add_message :error, 'Account not found to initiate the transfer'
          return
        end
    end
  end

  def init
    id = (params[:id] or params[:to_user_id])
    self.to_user = user.company.users.with_id(id).first rescue nil
    self.reports = to_user.reports.with_id(params[:report_ids]) if to_user
    self.report_names = []
    reports.each do |report|
      self.report_names << report.name
    end
    return if to_user.blank?

    self.reimbursement_type_id = params[:payment][:reimbursement_type_id].to_i

    if payment_params[:from_cash_in_hand].present?
      self.cash_in_hand_deduction_amount = payment_params[:from_cash_in_hand].to_f rescue nil
    end

    if user.admin? and admin_view?
      self.role = UserRole.admin_id
    elsif user.finance_manager? and finance_view?
      self.role = UserRole.finance_manager_id
    end

    case self.reimbursement_type_id
      when REIMBURSEMENT_TYPE[:outside_finly]
        if payment_params[:from_outside_finly].present?
          self.outside_settlement_amount = payment_params[:from_outside_finly].to_f rescue nil
        end
      when REIMBURSEMENT_TYPE[:reimbursement_card]
        return unless payment_params.dig(:from_reimbursement_card, :id).present?
        self.reimbursement_card_id = payment_params[:from_reimbursement_card][:id] rescue nil
        self.reimbursement_card = to_user.cards.with_id(reimbursement_card_id).first rescue nil

        if self.reimbursement_card.present?
          self.reimbursement_amount = payment_params[:from_reimbursement_card][:amount].to_f rescue 0

          self.initiating_account_type = payment_params[:initiating_account_type]

          case self.initiating_account_type.to_sym
            when :virtual_account
              self.initiating_account_id = user.company_id
              self.initiating_account = user.company
            when :wallet
              self.initiating_account_id = user.wallet.id
              self.initiating_account = user.wallet
            when :card
              self.initiating_account_id = payment_params[:initiating_account_id].to_i rescue nil
              if self.initiating_account_id.present?
                self.initiating_account = user.cards.with_id(self.initiating_account_id).first rescue nil
              end
          end
        end
      when REIMBURSEMENT_TYPE[:reimbursement_bank_account]
        return unless payment_params.dig(:reimbursement_bank_account, :amount).present?

        self.reimbursement_bank_account = to_user.itz_cash_dmt_sender&.beneficiaries&.active&.reimbursement_accounts&.default&.first

        if self.reimbursement_bank_account.present?
          self.reimbursement_amount = payment_params.dig(:reimbursement_bank_account, :amount).to_f rescue 0

          self.initiating_account_type = payment_params[:initiating_account_type]

          case self.initiating_account_type.to_sym
            when :virtual_account
              self.initiating_account_id = user.company_id
              self.initiating_account = user.company
            when :wallet
              self.initiating_account_id = user.wallet.id
              self.initiating_account = user.wallet
            when :card
              self.initiating_account_id = payment_params[:initiating_account_id].to_i rescue nil
              if self.initiating_account_id.present?
                self.initiating_account = user.cards.with_id(self.initiating_account_id).first rescue nil
              end
          end
        end
    end

  end

  def authorize
    unless to_user
      raise_unauthorized_exception
    end
    if reports.blank? or self.role.blank?
      raise_unauthorized_exception
    end

    team = User::Team::Index.(user, params)
    unless team.present? and team.include?(to_user)
      raise_unauthorized_exception
    end

  end

  def validate

    if params[:password].blank?
      add_message :error, 'You need to provide your password to initiate this transfer'
      return
    end
    unless user.valid_password?(params[:password])
      add_message :error, 'Invalid Password'
      return
    end

    # validating that the money deducted from cash in hand is actually less than the cash in hand on date of settlement
    cash_in_hand = to_user.cash_in_hand.value rescue 0

    if cash_in_hand_deduction_amount.present? and precision_value(cash_in_hand_deduction_amount) > precision_value(cash_in_hand)
      add_message :error, "Deduct Cash on Hand amount is greater than the cash on hand with #{to_user.name}"
    end

    unless self.reimbursement_type_id.present?
      add_message :error, 'Reimbursement Type not found'
      return
    end

    case self.reimbursement_type_id
      when REIMBURSEMENT_TYPE[:outside_finly]

      when REIMBURSEMENT_TYPE[:reimbursement_card]
        validate_reimbursement_card
        validate_initiating_account
      when REIMBURSEMENT_TYPE[:reimbursement_bank_account]
        validate_reimbursement_bank_account
        validate_initiating_account
    end

    # # Removed the check to ensure cash in hand deduction + settlement amount matches up as we would also be considering Reimbursements
    # # checking if cash in hand deduction + settlement amount matches up with report total
    # self.report_total = precision_value(reports.with_cash_expenses_total.sum(:value)).to_f
    # unless report_total == precision_value(reimbursement_amount + cash_in_hand_deduction_amount).to_f
    #   add_message :error, 'Reimbursement total does not match report totals'
    # end
    return if has_errors?

    self.report_total = precision_value(reports.with_reimbursable_expenses_total.sum(:value)).to_f

    cia_deduction_amount = cash_in_hand_deduction_amount.present? ? cash_in_hand_deduction_amount : 0
    outside_amount = outside_settlement_amount.present? ? outside_settlement_amount : 0
    r_amount = reimbursement_amount.present? ? reimbursement_amount : 0

    total = cia_deduction_amount
    total += outside_amount if reimbursement_type_id == REIMBURSEMENT_TYPE[:outside_finly]
    total += r_amount if reimbursement_type_id == REIMBURSEMENT_TYPE[:reimbursement_card]

    rep_total = 0
    reports.each do |report|
      rep_total += report.total_amount
    end

    if precision_value(total) > precision_value(rep_total)
      add_message :error, 'Settlement amount exceeds report total'
    end

  end

  def validate_initiating_account
    return unless self.reimbursement_amount.present?
    if self.initiating_account.blank?
      add_message :error, 'Account not found to initiate the fund transfer'
      return
    end
    if self.initiating_account_type == :card and not self.initiating_account.non_personal_fund_transfer
      add_message :error, 'Cannot use the selected card for processing reimbursements'
      return
    end

    if initiating_account_type == :wallet || initiating_account_type == 'wallet'
      unless user.wallet.balance_value > reimbursement_amount
        add_message :error, 'Not enough funds in your wallet to initiate transfer'
        return
      end
    end
  end

  def validate_reimbursement_card
    if self.reimbursement_card_id.present? and self.reimbursement_card.blank?
      add_message :error, 'Card not found to process reimbursement'
      return
    end

    return if self.reimbursement_card.blank?
    unless self.reimbursement_card.card_program.receive_reimbursement
      add_message :error, 'Selected card is not a Reimbursement Card'
      return
    end

    if self.reimbursement_amount.blank?
      add_message :error, 'Reimbursement Amount cannot be blank'
      return
    end

    if self.reimbursement_amount < 0
      add_message :error, 'Reimbursement amount has to be greater than 0'
      return
    end

    if outside_settlement_amount.present?
      add_message :error, 'Invalid Entry. You can either settle outside Finly or process the reimbursement through Finly Reimbursement Card but not both'
      return
    end
  end

  def validate_reimbursement_bank_account
    if self.reimbursement_bank_account.blank?
      add_message :error, 'Reimbursement Account not found to process reimbursement'
      return
    end

    return if has_errors?

    if self.reimbursement_amount.blank?
      add_message :error, 'Reimbursement Amount cannot be blank'
      return
    end

    if self.reimbursement_amount < 0
      add_message :error, 'Reimbursement amount has to be greater than 0'
      return
    end

    if outside_settlement_amount.present?
      add_message :error, 'Invalid Entry. You can either settle outside Finly or process the reimbursement through Finly Reimbursement Account but not both'
      return
    end
  end

  def process

    if self.cash_in_hand_deduction_amount.present?
      # creating a payment request that can handle this case
      self.payment_request = PaymentRequest.(user, nil, to_user.cash_on_hand.class.name, :debit, :balance_clearance_outside_finly)
      self.payment_request.add_payment_item(PaymentRequest::PaymentItem.(to_user, to_user.cash_on_hand, cash_in_hand_deduction_amount))

      op = AccountManager::Payments::PaymentProcessor.(user, {payment_request: payment_request})
      unless op.success?
        add_message :error, op.messages[:error]
        return
      end

      self.cash_deduction = op.payment_order.payments.first

    end
    ############ This concludes cash on hand deduction if any ################

    ############ Now the other reimbursement options #################
    if self.reimbursement_type_id == REIMBURSEMENT_TYPE[:reimbursement_card] and reimbursement_amount.present?

      initiating_account = nil
      case initiating_account_type
        when :virtual_account
          initiating_account = user.company.itz_cash_company_account
        when :wallet
          initiating_account = user.wallet
        when :card
          initiating_account = user.cards.with_id(initiating_account_id).first
        else
          # do nothing
      end

      self.payment_request = PaymentRequest.(user, initiating_account, reimbursement_card.class.name, :credit, :reimbursement)
      self.payment_request.add_payment_item(PaymentRequest::PaymentItem.(to_user, reimbursement_card, reimbursement_amount))

    elsif self.reimbursement_type_id == REIMBURSEMENT_TYPE[:outside_finly] and outside_settlement_amount.present?

      self.payment_request = PaymentRequest.(user, nil, nil, :credit, :reimbursement_outside_finly)
      self.payment_request.add_payment_item(PaymentRequest::PaymentItem.(to_user, nil, outside_settlement_amount))

    end

    op = AccountManager::Payments::PaymentProcessor.(user, {payment_request: payment_request})
    unless op.success?
      add_message :error, op.messages[:error]
      return
    end
    self.payment = op.payment_order.payments.first
    
    reports.each do |report|
      op = Report::MarkAsSettled.(user, {payment: payment, cash_in_hand_deduction: self.cash_deduction, report: report, role_id: role, view: params[:view]})
    end

  end

  def post_process
    add_message :success, 'Reports settled'

    event = Event::ESettlement::AddSettlement.new(user, payment: self.payment, cash_in_hand_deduction: cash_deduction,
                                                  from_cash_in_hand: cash_deduction,
                                                  reimbursement: {card: reimbursement_card, amount: reimbursement_amount})
    event.run
  end

end