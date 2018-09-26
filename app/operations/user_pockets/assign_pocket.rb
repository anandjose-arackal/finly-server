class UserPockets::AssignPocket < UserPockets::Base

  attr_accessor :assignable_pocket_templates, :selected_user, :assignable_pocket, :base_currency_id

  def authorized_user_types
    [:company_admin]
  end

  def init
    selected_user_id = params[:id] || params[:selected_user_id]
    self.selected_user = current_company.users.find_by(id: selected_user_id)

    # retrieving all the assignable pockets for this user
    op = UserPockets::AssignablePockets.(user, {selected_user_id: selected_user_id})
    if op.success?
      self.assignable_pocket_templates = op.pocket_templates
      assignable_pocket_id = params[:assignable_pocket_id]
      self.assignable_pocket = self.assignable_pocket_templates.find_by(id: assignable_pocket_id)
    else
      add_message :error, op.messages[:error]
      return
    end

    self.base_currency_id = params[:base_currency_id]
  end

  def validate
    if self.assignable_pocket.blank?
      add_message :error, "Invalid Pocket selected"
      return
    end

    if StringUtils.to_bool(params[:atm_withdrawal_pocket])
      if self.selected_user.user_pockets.atm_withdrawal_pockets.present?
        add_message :error, "You cannot have more than one ATM withdrawal pocket"
        return
      end
    end
  end

  def process
    pocket = self.selected_user.user_pockets.build(
                                                name: self.assignable_pocket.name,
                                                user_pocket_type_id: self.assignable_pocket.user_pocket_type_id,
                                                atm_withdrawal_pocket: StringUtils.to_bool(params[:atm_withdrawal_pocket]),
                                                company_pocket_template_id: self.assignable_pocket.id,
                                                base_currency_id: self.base_currency_id,
                                                balance_attributes: {
                                                    value: 0,
                                                    currency_id: self.base_currency_id
                                                }
    )
    if pocket.valid?
      pocket.save
    else
      add_message :error, pocket.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Successfully added pocket for user"
  end

end