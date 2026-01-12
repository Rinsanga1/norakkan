require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @cart = Cart.create!
    @product = Product.create!(
      name: "Test Coffee",
      description: "A test coffee product",
      roast_level: :medium,
      drinking_preference: :with_milk,
      flavour_profile: :balanced,
      equipment: :pourover,
      price: 15.99,
      inventory_quantity: 10,
      sku: "TEST-0001"
    )
  end

  test "should delete product successfully when not in any cart" do
    assert_difference("Product.count", -1) do
      delete product_url(@product)
    end

    assert_redirected_to products_path
    assert_equal "Product deleted successfully.", flash[:notice]
  end

  test "should not delete simple product when it is in a cart" do
    cart_item = @cart.cart_items.create!(
      product: @product,
      quantity: 1
    )

    assert_no_difference("Product.count") do
      delete product_url(@product)
    end

    assert_redirected_to product_url(@product)
    assert_equal "Cannot delete this product. It is currently in one or more shopping carts.", flash[:alert]
    assert cart_item.reload.persisted?
  end

  test "should not delete product with variant when variant is in a cart" do
    variant = @product.variants.create!(
      size: :_250g,
      grind: :wholebean,
      price: 15.99,
      inventory_quantity: 5,
      sku: "TEST-0001-001"
    )

    cart_item = @cart.cart_items.create!(
      variant: variant,
      quantity: 1
    )

    assert_no_difference("Product.count") do
      delete product_url(@product)
    end

    assert_redirected_to product_url(@product)
    assert_equal "Cannot delete this product. It is currently in one or more shopping carts.", flash[:alert]
    assert cart_item.reload.persisted?
  end

  test "should delete product with variant when variant is not in any cart" do
    variant = @product.variants.create!(
      size: :_250g,
      grind: :wholebean,
      price: 15.99,
      inventory_quantity: 5,
      sku: "TEST-0001-001"
    )

    assert_difference("Product.count", -1) do
      assert_difference("Variant.count", -1) do
        delete product_url(@product)
      end
    end

    assert_redirected_to products_path
    assert_equal "Product deleted successfully.", flash[:notice]
  end

  test "should not delete product when multiple variants are in different carts" do
    variant1 = @product.variants.create!(
      size: :_250g,
      grind: :wholebean,
      price: 15.99,
      inventory_quantity: 5,
      sku: "TEST-0001-001"
    )

    variant2 = @product.variants.create!(
      size: :_500g,
      grind: :french_press,
      price: 25.99,
      inventory_quantity: 3,
      sku: "TEST-0001-002"
    )

    cart2 = Cart.create!

    @cart.cart_items.create!(variant: variant1, quantity: 1)
    cart2.cart_items.create!(variant: variant2, quantity: 2)

    assert_no_difference("Product.count") do
      delete product_url(@product)
    end

    assert_redirected_to product_url(@product)
    assert_equal "Cannot delete this product. It is currently in one or more shopping carts.", flash[:alert]
  end
end
