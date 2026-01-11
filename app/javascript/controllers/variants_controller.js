import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["variants", "price", "variantId", "grind", "stockText", "stockStatus", "quantity", "submitButton"]

  connect() {
    this.variants = JSON.parse(this.variantsTarget.dataset.variants)
  }

  updateSize() {
    const selectedSize = this.element.querySelector("#size").value
    const grindSelect = this.element.querySelector("#grind")
    const submitButton = this.submitButtonTarget || this.element.querySelector('input[type="submit"]')

    // Clear previous options
    grindSelect.innerHTML = '<option value="">Select Grind</option>'

    if (!selectedSize) {
      grindSelect.disabled = true
      this.priceTarget.textContent = "--"
      this.variantIdTarget.value = ""
      this.updateStockStatus(null)
      if (submitButton) submitButton.disabled = true
      return
    }

    // Get available grinds for selected size
    const availableGrinds = this.variants
      .filter(v => v.size === selectedSize)
      .map(v => v.grind)
      .filter((value, index, self) => self.indexOf(value) === index) // unique

    // Populate grind dropdown
    availableGrinds.forEach(grind => {
      const option = document.createElement('option')
      option.value = grind
      option.textContent = this.humanize(grind)
      grindSelect.appendChild(option)
    })

    grindSelect.disabled = false
    this.updatePrice()
  }

  updatePrice() {
    const selectedSize = this.element.querySelector("#size").value
    const selectedGrind = this.element.querySelector("#grind").value
    const submitButton = this.submitButtonTarget || this.element.querySelector('input[type="submit"]')
    const quantityInput = this.quantityTarget || this.element.querySelector('input[name="quantity"]')

    if (!selectedSize || !selectedGrind) {
      this.priceTarget.textContent = "--"
      this.variantIdTarget.value = ""
      this.updateStockStatus(null)
      if (submitButton) submitButton.disabled = true
      return
    }

    const variant = this.variants.find(v =>
      v.size === selectedSize && v.grind === selectedGrind
    )

    if (variant) {
      this.priceTarget.textContent = `$${parseFloat(variant.price).toFixed(2)}`
      this.variantIdTarget.value = variant.id
      this.updateStockStatus(variant)

      // Set max quantity
      if (quantityInput) {
        quantityInput.max = variant.inventory_quantity
        quantityInput.value = Math.min(parseInt(quantityInput.value) || 1, variant.inventory_quantity)
      }

      if (submitButton) submitButton.disabled = variant.inventory_quantity <= 0
    } else {
      this.priceTarget.textContent = "Not available"
      this.variantIdTarget.value = ""
      this.updateStockStatus(null)
      if (submitButton) submitButton.disabled = true
    }
  }

  updateStockStatus(variant) {
    const stockText = this.stockTextTarget || this.stockStatusTarget?.querySelector('span')

    if (!variant || !stockText) return

    const quantity = variant.inventory_quantity

    if (quantity <= 0) {
      stockText.textContent = "Out of Stock"
      stockText.style.color = "red"
    } else if (quantity < 10) {
      stockText.textContent = `Low Stock - Only ${quantity} left`
      stockText.style.color = "orange"
    } else {
      stockText.textContent = `In Stock (${quantity} available)`
      stockText.style.color = "green"
    }
  }

  humanize(str) {
    return str.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase())
  }
}
