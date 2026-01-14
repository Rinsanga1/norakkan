class OrderMailer < ApplicationMailer
  def confirmation(order)
    @order = order
    @user = order.user
    @shipping_address = order.shipping_address

    mail(to: @user.email_address, subject: "Order Confirmed - #{@order.display_order_number}")
  end
end
