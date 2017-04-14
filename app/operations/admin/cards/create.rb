# this oepration will be used for updating all details of a particular card
# if it comes with an associated user_id, create it for that user
# if it comes with an associated company_id,create it as a company card that is not assigned to any user

class Admin::Cards::Create < Admin::Cards::Base

  attr_accessor :created_card, :selected_user, :card_create_params

  def pre_validate
    super()
    if user.blank? || params.blank?
      add_message :error, "Invalid params, try again"
      return
    end
  end

  def init
    if params[:user_id]
      self.selected_user = User.find_by(id: params[:user_id])
    else
      self.company = Company.find_by(id: params[:company_id])
    end
    self.card_create_params = card_params
  end

  def validate
    if selected_user.blank? && company.blank?
      add_message :error, "User or Company id needs to be sent"
      return
    end
  end

  def pre_process
    # todo - temporary, will be replaced with actual production product code once we get it
    card_create_params[:product_code] = "NGPRHD"
  end

  def process
    if selected_user.present?
      self.created_card = selected_user.cards.build(card_create_params)
      if created_card.save
        created_card.update(active: true)
      else
        add_message :error, created_card.errors.full_messages
        return
      end
    else
      self.created_card = company.cards.build(card_create_params)
      if created_card.save
        created_card.update(active: true)
      else
        add_message :error, created_card.errors.full_messages
        return
      end
    end
  end

  def post_process
    add_message :success, "Card created!"
  end

  def success
    Admin::Cards::Base::CardsPresenter.new(user, {card: created_card}, messages)
  end

end