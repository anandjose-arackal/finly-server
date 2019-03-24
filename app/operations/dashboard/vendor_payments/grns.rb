class Dashboard::VendorPayments::Grns < Dashboard::VendorPayments::Base
  attr_accessor :procurements

  def init
    self.procurements = Procurements::Grn::Pending::Index.(user, params).procurements
  end

  def success
    params[:procurements] = self.procurements
    Dashboard::VendorPayments::Grns::DashboardPresenter.new(user, params, messages)
  end


  class Dashboard::VendorPayments::Grns::DashboardPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :procurements, :counts

    has_scope :filter_procurement_type
    has_scope :filter_status_tags

    # General Filters from frontend
    has_scope :filter_policy_id
    has_scope :filter_department_id
    has_scope :filter_sub_department_id
    has_scope :filter_month
    has_scope :filter_year

    def init
      general_filter_params = {
        filter_policy_id: params[:filter_policy],
        filter_department_id: params[:filter_department],
        filter_sub_department_id: params[:filter_sub_department],
        filter_month: params[:filter_month],
        filter_year: params[:filter_year],
        filter_procurement_type: 'purchase_order'
      }

      self.procurements = params[:procurements]
      self.procurements = apply_scopes(self.procurements, general_filter_params)
      self.counts = []

      if user.is_goods_receiver?
        goods_receiver_data = {
          type: 'goods_receiver',
          data: [
            {
              title: "Total POs Awaiting Shipments",
              count: apply_scopes(procurements, {filter_status_tags: [7]})&.count,
              filters: []
            }
          ]
        }

        self.counts.push(goods_receiver_data)
      end
    end
  end
end