module Admin
  class UsersController < ApplicationController
    def index
      @search = params[:search]
      @sort_by = params[:sort_by] || "created_at"
      @sort_direction = params[:sort_direction] || "desc"

      @users = User.includes(:orders)

      if @search.present?
        @users = @users.where("email_address ILIKE ? OR full_name ILIKE ? OR phone ILIKE ?", "%#{@search}%", "%#{@search}%", "%#{@search}%")
      end

      case @sort_by
      when "total_spent"
        @users = @users.by_spending
      when "order_count"
        @users = @users.left_joins(:orders).group("users.id").select("users.*, COUNT(orders.id) as orders_count").order("orders_count #{@sort_direction}")
      when "average_order_value"
        @users = @users.left_joins(:orders).group("users.id").select("users.*, AVG(orders.total) as avg_order_value").order("avg_order_value #{@sort_direction} NULLS LAST")
      else
        @users = @users.order("#{@sort_by} #{@sort_direction}")
      end

      @users = @users.page(params[:page]).per(20)
    end

    def show
      @user = User.find(params[:id])
      @orders = @user.orders.includes(:shipping_address).order(created_at: :desc).page(params[:page]).per(10)
    end

    def export
      @users = User.includes(:orders).order(created_at: :desc)

      respond_to do |format|
        format.csv do
          headers["Content-Disposition"] = "attachment; filename=\"users_#{Date.current}.csv\""
          headers["Content-Type"] ||= "text/csv"
        end
      end
    end
  end
end
