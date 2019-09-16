class Dashboard::VendorPayments::Grns < Dashboard::VendorPayments::Base
  attr_accessor :procurements

  def init
    params[:filter_procurement_type] = "purchase_order"
    # params[:filter_status_tags] = [StatusTag.id_for(:receiving_shipment)]
    params[:filter_status_tags] = [StatusTag.id_for(:receiving_shipment), StatusTag.id_for(:po_approved), StatusTag.id_for(:po_sent)]

    params[:filter_creation_date_from] = params[:filter_date_from] if params[:filter_date_from].present?
    params[:filter_creation_date_to] = params[:filter_date_to] if params[:filter_date_to].present?
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
    has_scope :filter_location_id
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
        filter_procurement_type: 'purchase_order',
        filter_location_id: params[:filter_location]
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
              # count: apply_scopes(procurements, {filter_status_tags: [7]})&.count,
              count: apply_scopes(procurements, {filter_status_tags: [StatusTag.id_for(:receiving_shipment), StatusTag.id_for(:po_approved), StatusTag.id_for(:po_sent)]})&.count,
              filters: [{filter_creation_date_from: params[:filter_creation_date_from]}]
            }
          ]
        }

        self.counts.push(goods_receiver_data)
      end

      # Set Date Filters in Filters
      # Done becauase the filters in index page and the filters passed in dashboard for date filters are different
      self.counts.each do |count_object|
        count_object[:data].each do |data|
          if params[:filter_creation_date_from].present?
            date_filter_from = {filter_creation_date_from: params[:filter_creation_date_from]}
            data[:filters].push(date_filter_from)
          end

          if params[:filter_creation_date_to].present?
            date_filter_to = {filter_creation_date_to: params[:filter_creation_date_to]}
            data[:filters].push(date_filter_to)
          end
        end
      end
    end
  end
end