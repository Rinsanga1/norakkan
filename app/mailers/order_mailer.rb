class OrderMailer < ApplicationMailer
  def confirmation(order)
    @order = order
    @user = order.user
    @shipping_address = order.shipping_address

    mail(to: @user.email_address, subject: "Order Confirmed - #{@order.display_order_number}")
  end

  def status_updated(order)
    @order = order
    @user = order.user

    mail(
      to: @user.email_address,
      subject: "Order #{order.display_order_number} Status Update - #{order.status.titleize}"
    )
  end

  def payment_status_updated(order)
    @order = order
    @user = order.user

    mail(
      to: @user.email_address,
      subject: "Order #{order.display_order_number} Payment Status Update - #{order.payment_status.titleize}"
    )
  end
end
