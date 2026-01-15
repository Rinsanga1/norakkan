import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dashboard"
export default class extends Controller {
  static targets = ["timeRange"]

  connect() {
    this.loadCharts()
  }

  changeTimeRange(event) {
    const form = event.target.closest('form')
    form.requestSubmit()
  }

  loadCharts() {
    // Charts are loaded inline in the view for simplicity
    // In a production app, you might want to move this to a separate chart controller
  }
}