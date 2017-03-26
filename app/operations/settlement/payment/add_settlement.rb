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
                :initiating_account, :initiating_account_type, :initiating_account_id

  def authorized_user_types
    [:finance_manager, :admin]
  end

  def pre_validate
    super()
    from_cash_in_hand = params[:payment][:from_cash_in_hand].to_f rescue 0
    from_outside_finly = params[:payment][:from_outside_finly].to_f rescue 0
    from_reimbursement_card = params[:payment][:from_reimburesement_card][:amount] rescue 0
    if from_cash_in_hand < 0 or from_outside_finly < 0 or from_reimbursement_card < 0
      add_message :error, 'Reimbursement amount or cash in hand deduction cannot be negative'
      return
    end
    # if params[:payment][:from_cash_in_hand].to_f == 0 and params[:payment][:from_outside_finly].to_f == 0
    #   add_message :error, 'Reimbursement amount and cash in hand deduction cannot both be equal to 0'
    #   return
    # end
    if params[:report_ids].blank?
      add_message :error, 'No reports to reimburse'
    end

    if params[:payment].present? and params[:payment][:from_reimbursement_card]
      initiating_account_id = params[:payment][:initiating_account_id].to_sym rescue nil
      initiating_account_type = params[:payment][:initiating_account_type].to_sym rescue nil
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

    self.outside_settlement_amount = payment_params[:from_outside_finly].to_f rescue nil

    self.cash_in_hand_deduction_amount = payment_params[:from_cash_in_hand].to_f rescue nil

    self.reimbursement_card_id = payment_params[:from_reimbursement_card][:id] rescue nil
    if reimbursement_card_id.present?
      self.reimbursement_card = to_user.cards.with_id(reimbursement_card_id).first rescue nil
    end

    if self.reimbursement_card.present?
      self.reimbursement_amount = payment_params[:from_reimbursement_card][:amount].to_f rescue nil

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

  def authorize
    unless to_user
      raise_unauthorized_exception
    end
    if reports.blank?
      raise_unauthorized_exception
    end
    if user.admin? and admin_view?
      self.role = UserRole.admin_id
    else
      self.role = UserRole.finance_manager_id
    end
    team = User::Team::Index.(user, params)
    unless team.success? and team.include?(to_user)
      raise_unauthorized_exception
    end

  end

  def validate
    unless validate_date payment_params[:date]
      return false
    end

    if params[:password].blank?
      add_message :error, 'You need to provide your password to initiate this transfer'
      return
    end
    unless user.valid_password?(params[:password])
      add_message :error, 'Invalid Password'
      return
    end

    # payment_date = Date.parse(payment_params[:date])
    # validating that the money deducted from cash in hand is actually less than the cash in hand on date of settlement
    cash_in_hand = to_user.cash_in_hand.value rescue 0

    if cash_in_hand_deduction_amount.present? and precision_value(cash_in_hand_deduction_amount) > precision_value(cash_in_hand)
      add_message :error, "You cannot deduct more cash than the employee has on #{payment_params[:date].to_s}"
    end

    validate_reimbursement_card
    validate_initiating_account
    # # Removed the check to ensure cash in hand deduction + settlement amount matches up as we would also be considering Reimbursements
    # # checking if cash in hand deduction + settlement amount matches up with report total
    # self.report_total = precision_value(reports.with_cash_expenses_total.sum(:value)).to_f
    # unless report_total == precision_value(reimbursement_amount + cash_in_hand_deduction_amount).to_f
    #   add_message :error, 'Reimbursement total does not match report totals'
    # end
    return if has_errors?
    self.report_total = precision_value(reports.with_cash_expenses_total.sum(:value)).to_f
    cia_deduction_amount = cash_in_hand_deduction_amount.present? ? cash_in_hand_deduction_amount : 0
    outside_amount = outside_settlement_amount.present? ? outside_settlement_amount : 0
    r_amount = reimbursement_amount.present? ? reimbursement_amount : 0
    if cia_deduction_amount + outside_amount + r_amount > report_total
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

  def process
    balance_sheet = to_user.balance_sheet

    if self.cash_in_hand_deduction_amount.present?
      # deducting cash in hand given in the params
      self.cash_deduction = to_user.payments.build(initiating_user: user, receiving_user: to_user,
                                                   payment_type_id: PaymentType.id_for(:deduct_cash_on_hand),
                                                   date: payment_params[:date],
                                                   note: "Reimbursement deduction for reports: #{report_names.to_sentence}",
                                                   amount_attributes: {value: cash_in_hand_deduction_amount,
                                                                       currency_id: payment_params[:currency_id]})
      unless cash_deduction.valid?
        add_message :error, cash_deduction.errors.full_messages
        return
      end
    end

    if reimbursement_amount.present?
      self.payment = to_user.payments.build(initiating_user: user, receiving_user: to_user,
                                            payment_type_id: PaymentType.id_for(:reimbursement),
                                            date: Date.today, note: payment_params[:note],
                                            initiating_account: self.initiating_account,
                                            receiving_account: self.reimbursement_card,
                                            amount_attributes: {value: reimbursement_amount,
                                                                currency_id: payment_params[:currency_id]})
      unless self.payment.valid?
        add_message :error, self.payment.errors.full_messages
        return
      end

      case initiating_account_type
        when :virtual_account
          # Do nothing
        when :wallet
          # Subtract the reimbursement amount from wallet
          wallet = user.wallet
          unless wallet.subtract_funds(self.amount)
            add_message :error, wallet.errors.full_messages
            return
          end
        when :card
          # Debit the reimbursement amount from card
          debit_result = ItzCash::Debit.(user, card_id: initiating_account_id, amount: self.amount)
          unless debit_result.success?
            add_message :error, debit_result.messages[:error]
            return
          end
      end

      result = ItzCash::Credit.(to_user, card_id: reimbursement_card.id, amount: self.amount)
      unless result.success?
        add_message :error, result.messages[:error]
        return
      end

      self.payment.save

    elsif outside_settlement_amount.present?
      self.payment = to_user.payments.build(initiating_user: user, receiving_user: to_user,
                                            payment_type_id: PaymentType.id_for(:reimbursement_outside_finly),
                                            date: payment_params[:date], note: payment_params[:note],
                                            amount_attributes: {value: outside_settlement_amount, currency_id: payment_params[:currency_id]})
      if self.payment.save
        balance_sheet.subtract_approved_reports_total report_total, Currency.first.id
      else
        add_message :error, self.payment.errors.full_messages
      end
    end

    if self.cash_in_hand_deduction_amount.present?
      # deducting cash in hand given in the params
      bs = to_user.balance_sheet
      if bs.subtract_cash_in_hand(cash_in_hand_deduction_amount)
        self.cash_deduction.save
      else
        add_message :error, bs.errors.full_messages
        return
      end
    end

    reports.each do |report|
      Report::MarkAsSettled.(user, {payment: payment, report: report, role_id: role})
    end

    # if outside_settlement_amount == 0
    #   if cash_deduction.save and balance_sheet.subtract_approved_reports_total report_total, Currency.first.id
    #     # subtract the respective amount from the user's cash in hand
    #     to_user.balance_sheet.subtract_cash_in_hand(cash_in_hand_deduction_amount)
    #     # mark the reports as reimbursed
    #     reports.each do |report|
    #       Report::MarkAsSettled.(user, {from_cash_in_hand: cash_deduction, report: report, role_id: role})
    #     end
    #     return
    #   else
    #     add_message :error, cash_deduction.errors.full_messages + balance_sheet.errors.full_messages
    #   end
    # elsif cash_in_hand_deduction_amount == 0
    #   if payment.save and balance_sheet.subtract_approved_reports_total report_total, Currency.first.id
    #     # mark the reports as reimbursed
    #     reports.each do |report|
    #       Report::MarkAsSettled.(user, {payment: payment, report: report, role_id: role})
    #     end
    #   else
    #     add_message :error, payment.errors.full_messages + balance_sheet.errors.full_messages
    #   end
    # else
    #   if payment.save and cash_deduction.save and balance_sheet.subtract_approved_reports_total report_total, Currency.first.id
    #     # subtract the respective amount from the user's cash in hand
    #     to_user.balance_sheet.subtract_cash_in_hand(payment_params[:from_cash_in_hand].to_f)
    #     # mark all the reports as reimbursed
    #     reports.each do |report|
    #       Report::MarkAsSettled.(user, {payment: payment, from_cash_in_hand: cash_deduction, report: report, role_id: role})
    #     end
    #   else
    #     add_message :error, payment.errors.full_messages + cash_deduction.errors.full_messages + balance_sheet.errors.full_messages
    #   end
    # end
  end

  def post_process
    add_message :success, 'Reports settled'

    event = Event::ESettlement::AddSettlement.new(user, payment: self.payment, cash_in_hand_deduction: cash_deduction,
                                                  from_cash_in_hand: cash_deduction,
                                                  reimbursement: {card: reimbursement_card, amount: reimbursement_amount})
    event.run
  end
  
end