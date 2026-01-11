class CartItemsController < ApplicationController
  def create
    if params[:variant_id].present?
      # Product with variants
      @cart_item = @cart.cart_items.find_by(variant_id: params[:variant_id])
      if @cart_item
        @cart_item.increment!(:quantity)
      else
        @cart.cart_items.create!(variant_id: params[:variant_id], quantity: 1)
      end
    elsif params[:product_id].present?
      # Product without variants
      @cart_item = @cart.cart_items.find_by(product_id: params[:product_id], variant_id: nil)
      if @cart_item
        @cart_item.increment!(:quantity)
      else
        @cart.cart_items.create!(product_id: params[:product_id], quantity: 1)
      end
    end
    redirect_to cart_path(@cart)
  end

  def destroy
    @cart_item = @cart.cart_items.find(params[:id])
    @cart_item.destroy
    redirect_to cart_path(@cart)
  end
end
