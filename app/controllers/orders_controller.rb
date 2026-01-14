class OrdersController < ApplicationController
  before_action :require_authentication
  before_action :set_order, only: [ :show, :confirmation ]

  def index
    @orders = current_user.orders.recent
  end

  def show
    redirect_to orders_path, alert: "Order not found" unless @order.user == current_user
  end

  def confirmation
    redirect_to orders_path, alert: "Order not found" unless @order.user == current_user
  end

  private

  def set_order
    @order = Order.find_by(id: params[:id])
  end
end
