class CheckoutsController < ApplicationController
  before_action :require_authentication
  before_action :set_cart
  before_action :set_order, only: [ :new, :create ]

  def new
    default_address = current_user.default_shipping_address

    @checkout_form = CheckoutForm.new(
      name: default_address&.name || current_user.full_name || current_user.email_address.split("@").first,
      phone: default_address&.phone || current_user.phone,
      address_line_1: default_address&.address_line_1,
      address_line_2: default_address&.address_line_2,
      city: default_address&.city,
      state: default_address&.state,
      postal_code: default_address&.postal_code,
      country: default_address&.country || "India"
    )
  end

  def create
    @checkout_form = CheckoutForm.new(checkout_params)

    if @checkout_form.use_saved_address == "true"
      @order.shipping_address = current_user.shipping_addresses.find(@checkout_form.shipping_address_id)
    else
      new_address = current_user.shipping_addresses.build(
        name: @checkout_form.name,
        phone: @checkout_form.phone,
        address_line_1: @checkout_form.address_line_1,
        address_line_2: @checkout_form.address_line_2,
        city: @checkout_form.city,
        state: @checkout_form.state,
        postal_code: @checkout_form.postal_code,
        country: @checkout_form.country
      )

      if new_address.save
        @order.shipping_address = new_address

        if @checkout_form.save_address == "1" && @checkout_form.address_label.present?
          new_address.update(label: @checkout_form.address_label)
        end
      else
        new_address.errors.full_messages.each do |message|
          @checkout_form.errors.add(:base, message)
        end
        render :new, status: :unprocessable_entity
        return
      end
    end

    @order.notes = @checkout_form.notes if @checkout_form.notes.present?

    if @order.save
      razorpay_order = Razorpay::Order.create(
        amount: (@order.total * 100).to_i,
        currency: "INR",
        receipt: @order.display_order_number,
        notes: { order_id: @order.id }
      )
      @order.update!(razorpay_order_id: razorpay_order.id)

      render :payment, locals: { razorpay_order_id: @order.razorpay_order_id }
    else
      render :new, status: :unprocessable_entity
    end
  end

  def payment_callback
    @order = Order.find_by(id: params[:order_id])

    if @order.nil? || @order.user != current_user
      redirect_to root_path, alert: "Order not found"
      return
    end

    if params[:razorpay_payment_id].present?
      session_cart = Cart.find_by(id: session[:cart_id])
      session_cart&.cart_items&.destroy_all

      @order.update!(
        status: :paid,
        payment_status: :completed
      )

      OrderMailer.confirmation(@order).deliver_later

      redirect_to order_confirmation_path(@order), notice: "Payment successful! Order confirmed."
    else
      @order.update!(payment_status: :failed)
      redirect_to new_checkout_path, alert: "Payment failed. Please try again."
    end
  end

  def webhook
    webhook_body = request.raw_post

    head :ok
  rescue => e
    Rails.logger.error("Razorpay webhook error: #{e.message}")
    head :bad_request
  end

  private

  def set_order
    @order = @cart.create_order_from_cart(current_user)
  end

  def checkout_params
    params.require(:checkout_form).permit(
      :name, :phone, :address_line_1, :address_line_2,
      :city, :state, :postal_code, :country, :notes,
      :save_address, :address_label, :use_saved_address, :shipping_address_id
    )
  end
end
