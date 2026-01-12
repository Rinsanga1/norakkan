class CartItemsController < ApplicationController
  def create
    quantity = params[:quantity].to_i || 1

    if params[:variant_id].present?
      variant = Variant.find(params[:variant_id])

      # Check stock availability
      unless variant.in_stock?
        redirect_to product_path(variant.product), alert: "This variant is out of stock."
        return
      end

      unless variant.available_quantity?(quantity)
        redirect_to product_path(variant.product), alert: "Only #{variant.inventory_quantity} available in stock."
        return
      end

      # Product with variants
      @cart_item = @cart.cart_items.find_by(variant_id: params[:variant_id])
      if @cart_item
        new_quantity = @cart_item.quantity + quantity
        unless variant.available_quantity?(new_quantity)
          redirect_to product_path(variant.product), alert: "Cannot add more. Only #{variant.inventory_quantity} available in stock."
          return
        end
        @cart_item.update(quantity: new_quantity)
      else
        @cart.cart_items.create!(variant_id: params[:variant_id], quantity: quantity)
      end

    elsif params[:product_id].present?
      product = Product.find(params[:product_id])

      # Check stock availability
      unless product.in_stock?
        redirect_to product_path(product), alert: "This product is out of stock."
        return
      end

      unless product.inventory_quantity >= quantity
        redirect_to product_path(product), alert: "Only #{product.inventory_quantity} available in stock."
        return
      end

      # Product without variants
      @cart_item = @cart.cart_items.find_by(product_id: params[:product_id], variant_id: nil)
      if @cart_item
        new_quantity = @cart_item.quantity + quantity
        unless product.inventory_quantity >= new_quantity
          redirect_to product_path(product), alert: "Cannot add more. Only #{product.inventory_quantity} available in stock."
          return
        end
        @cart_item.update(quantity: new_quantity)
      else
        @cart.cart_items.create!(product_id: params[:product_id], variant_id: nil, quantity: quantity)
      end
    end

    redirect_to cart_path(@cart), notice: "Item added to cart successfully."
  end

  def update
    @cart_item = @cart.cart_items.find(params[:id])
    new_quantity = params[:quantity].to_i

    if new_quantity < 1
      redirect_to cart_path(@cart), alert: "Quantity must be at least 1."
      return
    end

    # Check stock availability
    if @cart_item.variant
      unless @cart_item.variant.available_quantity?(new_quantity)
        redirect_to cart_path(@cart), alert: "Only #{@cart_item.variant.inventory_quantity} available in stock."
        return
      end
    elsif @cart_item.product
      unless @cart_item.product.inventory_quantity >= new_quantity
        redirect_to cart_path(@cart), alert: "Only #{@cart_item.product.inventory_quantity} available in stock."
        return
      end
    end

    if @cart_item.update(quantity: new_quantity)
      redirect_to cart_path(@cart), notice: "Cart updated successfully."
    else
      redirect_to cart_path(@cart), alert: "Failed to update cart."
    end
  end

  def destroy
    @cart_item = @cart.cart_items.find(params[:id])
    @cart_item.destroy
    redirect_to cart_path(@cart), notice: "Item removed from cart."
  end
end
