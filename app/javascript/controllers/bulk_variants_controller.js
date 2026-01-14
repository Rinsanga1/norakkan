import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "size", "price", "inventory", "grindCheckbox", "preview"]

  connect() {
    this.variantIndex = this.element.dataset.startIndex || 0
  }

  updatePreview() {
    const size = this.sizeTarget.value
    const price = this.priceTarget.value
    const inventory = this.inventoryTarget.value
    const selectedGrinds = this.getSelectedGrinds()

    if (!size || !price || selectedGrinds.length === 0) {
      this.previewTarget.innerHTML = '<p style="color: #666;">Select size, price, and at least one grind to see preview...</p>'
      return
    }

    const previewHtml = `
      <div style="background: #f8f9fa; padding: 15px; border-radius: 5px; margin-top: 10px;">
        <h5 style="margin-top: 0;">Will create ${selectedGrinds.length} variant(s):</h5>
        <ul style="margin: 10px 0; padding-left: 20px;">
          ${selectedGrinds.map(grind => `
            <li>${this.humanize(size)} - ${this.humanize(grind)} - $${parseFloat(price).toFixed(2)} (${inventory} in stock)</li>
          `).join('')}
        </ul>
      </div>
    `
    this.previewTarget.innerHTML = previewHtml
  }

  getSelectedGrinds() {
    return Array.from(this.grindCheckboxTargets)
      .filter(checkbox => checkbox.checked)
      .map(checkbox => checkbox.value)
  }

  addVariants(event) {
    event.preventDefault()

    const size = this.sizeTarget.value
    const price = this.priceTarget.value
    const inventory = this.inventoryTarget.value
    const selectedGrinds = this.getSelectedGrinds()

    if (!size || !price || selectedGrinds.length === 0) {
      alert('Please select size, enter price, and check at least one grind option')
      return
    }

    const variantsContainer = document.getElementById('variants-container')

    selectedGrinds.forEach(grind => {
      const variantHtml = this.createVariantHtml(size, grind, price, inventory)
      variantsContainer.insertAdjacentHTML('beforeend', variantHtml)
      this.variantIndex++
    })

    this.resetForm()
    this.showSuccessMessage(selectedGrinds.length)
  }

  createVariantHtml(size, grind, price, inventory) {
    const index = this.variantIndex
    return `
      <div class="nested-fields" style="border: 1px solid #ddd; padding: 15px; margin-bottom: 15px; border-radius: 5px; background: white;">
        <h5>Variant: ${this.humanize(size)} - ${this.humanize(grind)}</h5>
        <div style="display: grid; grid-template-columns: 1fr 1fr 1fr 1fr auto; gap: 15px; align-items: end;">
          <div>
            <label>Size</label>
            <select name="product[variants_attributes][${index}][size]" required style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px;">
              <option value="${size}" selected>${this.humanize(size)}</option>
            </select>
          </div>
          <div>
            <label>Grind</label>
            <select name="product[variants_attributes][${index}][grind]" required style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px;">
              <option value="${grind}" selected>${this.humanize(grind)}</option>
            </select>
          </div>
          <div>
            <label>Price</label>
            <input type="number" name="product[variants_attributes][${index}][price]" step="0.01" min="0" value="${price}" required style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px;">
          </div>
          <div>
            <label>Stock Quantity</label>
            <input type="number" name="product[variants_attributes][${index}][inventory_quantity]" min="0" value="${inventory}" required style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px;">
          </div>
          <div>
            <button type="button" onclick="this.closest('.nested-fields').remove()" style="padding: 8px 15px; background: #dc3545; color: white; border: none; border-radius: 4px; cursor: pointer;">
              Remove
            </button>
          </div>
        </div>
      </div>
    `
  }

  resetForm() {
    this.sizeTarget.value = ''
    this.priceTarget.value = ''
    this.inventoryTarget.value = '0'
    this.grindCheckboxTargets.forEach(checkbox => checkbox.checked = false)
    this.previewTarget.innerHTML = '<p style="color: #666;">Select size, price, and at least one grind to see preview...</p>'
  }

  showSuccessMessage(count) {
    const message = document.createElement('div')
    message.style.cssText = 'position: fixed; top: 20px; right: 20px; background: #28a745; color: white; padding: 15px 20px; border-radius: 5px; box-shadow: 0 2px 10px rgba(0,0,0,0.2); z-index: 1000;'
    message.textContent = `✓ Added ${count} variant(s) successfully!`
    document.body.appendChild(message)

    setTimeout(() => {
      message.style.opacity = '0'
      message.style.transition = 'opacity 0.3s'
      setTimeout(() => message.remove(), 300)
    }, 2000)
  }

  humanize(str) {
    return str.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase())
  }
}
