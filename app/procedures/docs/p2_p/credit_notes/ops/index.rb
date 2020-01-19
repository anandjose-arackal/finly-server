class Docs::P2P::CreditNotes::Ops::Index < Transactions::API
  include HasScope

  has_scope :filter_search
  has_scope :filter_sequence_id
  has_scope :filter_credit_note_number
  has_scope :filter_status
  has_scope :filter_adjustables


  has_scope :filter_department_id
  has_scope :filter_cost_center_id
  has_scope :filter_location_id
  has_scope :filter_policy_id
  has_scope :filter_user_id
  has_scope :filter_vendor_id

  has_scope :filter_invoice_id
  has_scope :filter_invoice_number

  has_scope :filter_date, using: [:from, :to], type: :hash
  has_scope :filter_created_on_date, using: [:from, :to], type: :hash
  has_scope :filter_approved_on_date, using: [:from, :to], type: :hash
  has_scope :filter_amount, using: [:gteq, :lteq], type: :hash


  step Policy::Pundit(Docs::P2P::CreditNotes::Authorizer, :index?)
  # step Resolver::Transactions::Load(model: BbpsBillerSubscription, scope: :default, filter: true, paginate: true)
  step :index!

  # def check(options, params:, **)
  # end
  #
  # def check2(options, params:, **)
  # end

  def index!(options, params:, current_user:, **)
    if current_user.vendor_payment_admin?
      admin_restricted_status_ids = [CreditNoteStatus.id_for(:draft)]
      credit_notes = CreditNote.role_based_admin_associated_items(current_user, UserRole.id_for(:admin), {admin_restricted_status_ids: admin_restricted_status_ids}).or(current_user.credit_notes)
    elsif current_user.policy_user_roles.pluck(:user_role_id).uniq.present?
      credit_notes = CreditNote.associated_items(current_user, CreditNote.roles) || CreditNote.none
    else
      credit_notes = CreditNote.none
    end

    page = params[:page] || 1
    per_page = params[:per_page] || 30
    credit_notes = apply_scopes(credit_notes, params)
    result = {
        "credit_notes" => credit_notes.sort_for_index.paginate(page: page, per_page: per_page).includes_for_index
    }
    options['result'] = result
  end
end