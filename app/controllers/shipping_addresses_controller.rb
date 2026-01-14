class ShippingAddressesController < ApplicationController
  before_action :require_authentication

  def index
    @shipping_addresses = current_user.shipping_addresses.recent
  end

  def create
    @shipping_address = current_user.shipping_addresses.build(shipping_address_params)

    if @shipping_address.save
      @shipping_address.set_as_default! if current_user.shipping_addresses.count == 1

      respond_to do |format|
        format.turbo_stream { render turbo_stream: @shipping_address }
        format.html { redirect_to settings_shipping_addresses_path, notice: "Address saved!" }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @shipping_address = current_user.shipping_addresses.find(params[:id])

    if @shipping_address.update(shipping_address_params)
      @shipping_address.set_as_default! if params[:set_default]

      respond_to do |format|
        format.turbo_stream { render turbo_stream: @shipping_address }
        format.html { redirect_to settings_shipping_addresses_path, notice: "Address updated!" }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @shipping_address = current_user.shipping_addresses.find(params[:id])
    @shipping_address.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to settings_shipping_addresses_path, notice: "Address deleted!" }
    end
  end

  def set_default
    @shipping_address = current_user.shipping_addresses.find(params[:id])
    @shipping_address.set_as_default!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to settings_shipping_addresses_path, notice: "Default address updated!" }
    end
  end

  private

  def shipping_address_params
    params.require(:shipping_address).permit(
      :label, :name, :address_line_1, :address_line_2,
      :city, :state, :postal_code, :country, :phone
    )
  end
end
