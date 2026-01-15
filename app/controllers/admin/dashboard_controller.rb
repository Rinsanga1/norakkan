module Admin
  class DashboardController < ApplicationController
  def index
    @time_range = params[:time_range] || :this_month
    @metrics = ::Dashboard::MetricsService.new(@time_range)

    respond_to do |format|
      format.html
      format.json { render json: dashboard_data }
    end
  end

  def analytics
    @time_range = params[:time_range] || :this_month
    @metrics = ::Dashboard::MetricsService.new(@time_range)
  end

    private

    def dashboard_data
      {
        total_sales: @metrics.total_sales,
        total_orders: @metrics.total_orders,
        average_order_value: @metrics.average_order_value,
        active_customers: @metrics.active_customers,
        orders_by_status: @metrics.orders_by_status,
        sales_by_date: @metrics.sales_by_date,
        top_products: @metrics.top_products.map { |p| { name: p.name, sales: p.total_sales } },
        top_customers: @metrics.top_customers.map { |c| { name: c.full_name || c.email_address, spent: c.total_spent, orders: c.order_count } },
        recent_orders: @metrics.recent_orders.map do |order|
          {
            id: order.id,
            order_number: order.display_order_number,
            customer_name: order.user.name,
            total: order.total,
            status: order.status,
            payment_status: order.payment_status,
            created_at: order.created_at
          }
        end
      }
    end
  end
end
