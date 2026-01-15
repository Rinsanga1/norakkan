import { Controller } from "@hotwired/stimulus"
import Chart from "chart.js/auto"

// Connects to data-controller="chart"
export default class extends Controller {
  static values = {
    type: String,
    data: Object,
    options: Object
  }

  connect() {
    this.renderChart()
  }

  renderChart() {
    if (this.chart) {
      this.chart.destroy()
    }

    this.chart = new Chart(this.element, {
      type: this.typeValue || 'line',
      data: this.dataValue,
      options: this.optionsValue || {}
    })
  }

  disconnect() {
    if (this.chart) {
      this.chart.destroy()
    }
  }
}