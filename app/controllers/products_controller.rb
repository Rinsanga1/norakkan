class ProductsController < ApplicationController
  def index
    @products = Product.all
  end

  def show
    @product = Product.find(params[:id])
  end

  def new
    @product = Product.new
    # Don't build empty variant - let user add if needed
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to @product, notice: "Product created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @product = Product.find(params[:id])
  end

  def update
    @product = Product.find(params[:id])
    if @product.update(product_params)
      redirect_to @product, notice: "Product updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product = Product.find(params[:id])

    if @product.cart_items.any? || @product.variants.any? { |v| v.cart_items.any? }
      redirect_to @product, alert: "Cannot delete this product. It is currently in one or more shopping carts."
      return
    end

    @product.destroy
    redirect_to products_path, notice: "Product deleted successfully."
  end

  def purge_image
    @product = Product.find(params[:id])
    image = @product.images.find(params[:image_id])
    image.purge
    redirect_to edit_product_path(@product), notice: "Image removed successfully."
  end

  private

  def product_params
  params.require(:product).permit(
    :name,
    :description,
    :roast_level,
    :drinking_preference,
    :flavour_profile,
    :equipment,
    :stock,
    :price,
    :inventory_quantity,
    :sku,
    # Remove :has_variants - it's just a UI checkbox, not a database field
    images: [],  # Allow multiple images (for simple products)
    variants_attributes: [ :id, :size, :grind, :price, :inventory_quantity, :sku, :_destroy ]
  )
  end
end
