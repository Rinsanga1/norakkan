module Dashboard
  class MetricsService
    attr_reader :time_range

    def initialize(time_range = :this_month)
      @time_range = time_range
    end

    def orders
      @orders ||= Order.where(created_at: date_range)
    end

    def users
      @users ||= User.where(created_at: date_range)
    end

    def total_sales
      orders.where(payment_status: :paid).sum(:total)
    end

    def total_orders
      orders.count
    end

    def average_order_value
      return 0 if total_orders.zero?
      total_sales / total_orders
    end

    def active_customers
      orders.distinct.pluck(:user_id).size
    end

    def orders_by_status
      orders.group(:status).count
    end

    def sales_by_date
      orders.where(payment_status: :paid)
            .group("DATE(created_at)")
            .sum(:total)
            .sort_by { |date, _| date }
    end

    def top_products
      OrderItem.joins(:order, :product)
               .where(orders: { created_at: date_range, payment_status: :paid })
               .group(:product_id)
               .select("products.name, SUM(order_items.subtotal) as total_sales, SUM(order_items.quantity) as total_quantity")
               .order("total_sales DESC")
               .limit(10)
    end

    def top_customers
      orders.where(payment_status: :paid)
            .joins(:user)
            .group(:user_id)
            .select("users.id, users.full_name, users.email_address, SUM(orders.total) as total_spent, COUNT(orders.id) as order_count")
            .order("total_spent DESC")
            .limit(10)
    end

    def recent_orders(limit = 10)
      orders.includes(:user, :shipping_address).order(created_at: :desc).limit(limit)
    end

    private

    def date_range
      case time_range.to_sym
      when :today
        Date.current.beginning_of_day..Date.current.end_of_day
      when :last_7_days
        7.days.ago.beginning_of_day..Time.current
      when :last_30_days
        30.days.ago.beginning_of_day..Time.current
      when :this_month
        Date.current.beginning_of_month.beginning_of_day..Date.current.end_of_month.end_of_day
      when :all_time
        Date.new(2020, 1, 1)..Time.current
      else
        Date.current.beginning_of_month.beginning_of_day..Date.current.end_of_month.end_of_day
      end
    end
  end
end
