import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["variants", "price", "variantId", "size", "grind"]

  connect() {
    this.variants = JSON.parse(this.variantsTarget.dataset.variants)
    this.updatePrice()
  }

  updatePrice() {
    const selectedSize = this.element.querySelector("#size").value
    const selectedGrind = this.element.querySelector("#grind").value
    const variant = this.variants.find(v => v.size === selectedSize && v.grind === selectedGrind)

    if (variant) {
      this.priceTarget.textContent = variant.price
      this.variantIdTarget.value = variant.id
    } else {
      this.priceTarget.textContent = "Not available"
      this.variantIdTarget.value = ""
    }
  }
}
