import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="order-status"
export default class extends Controller {
  static targets = ["status", "paymentStatus", "notes"]

  update(event) {
    event.preventDefault()

    const form = event.target
    const formData = new FormData(form)

    fetch(form.action, {
      method: form.method,
      body: formData,
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
        'Accept': 'text/vnd.turbo-stream.html'
      }
    })
    .then(response => {
      if (response.ok) {
        return response.text()
      } else {
        throw new Error('Network response was not ok')
      }
    })
    .then(html => {
      // Turbo Stream will handle the response
    })
    .catch(error => {
      console.error('Error updating order:', error)
      alert('Error updating order. Please try again.')
    })
  }
}