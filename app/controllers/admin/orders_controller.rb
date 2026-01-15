module Admin
  class OrdersController < ApplicationController
    before_action :set_order, only: [ :show, :update ]

    def index
      @status_filter = params[:status]
      @payment_status_filter = params[:payment_status]
      @search = params[:search]
      @start_date = params[:start_date].presence || 30.days.ago.to_date
      @end_date = params[:end_date].presence || Date.current

      @orders = Order.includes(:user, :shipping_address)
                     .where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                     .order(created_at: :desc)

      @orders = @orders.where(status: @status_filter) if @status_filter.present?
      @orders = @orders.where(payment_status: @payment_status_filter) if @payment_status_filter.present?

      if @search.present?
        @orders = @orders.joins(:user).where("users.email_address ILIKE ? OR users.full_name ILIKE ? OR orders.id::text = ?", "%#{@search}%", "%#{@search}%", @search)
      end

      @orders = @orders.page(params[:page]).per(20)
    end

    def show
      @order_items = @order.order_items.includes(:product, :variant)
    end

    def update
      old_status = @order.status
      old_payment_status = @order.payment_status

      if @order.update(order_params)
        # Send notifications if status changed
        OrderMailer.status_updated(@order).deliver_later if @order.status != old_status
        OrderMailer.payment_status_updated(@order).deliver_later if @order.payment_status != old_payment_status

        respond_to do |format|
          format.html { redirect_to admin_order_path(@order), notice: "Order updated successfully." }
          format.turbo_stream { render turbo_stream: turbo_stream.replace("order_#{@order.id}", partial: "admin/orders/order_row", locals: { order: @order }) }
        end
      else
        respond_to do |format|
          format.html { render :show, status: :unprocessable_entity }
          format.turbo_stream { render turbo_stream: turbo_stream.replace("order_form", partial: "admin/orders/form", locals: { order: @order }) }
        end
      end
    end

    def export
      @start_date = params[:start_date].presence || 30.days.ago.to_date
      @end_date = params[:end_date].presence || Date.current

      @orders = Order.includes(:user, :shipping_address, :order_items)
                     .where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                     .order(created_at: :desc)

      respond_to do |format|
        format.csv do
          headers["Content-Disposition"] = "attachment; filename=\"orders_#{@start_date}_to_#{@end_date}.csv\""
          headers["Content-Type"] ||= "text/csv"
        end
      end
    end

    private

    def set_order
      @order = Order.find(params[:id])
    end

    def order_params
      params.require(:order).permit(:status, :payment_status, :notes)
    end
  end
end
