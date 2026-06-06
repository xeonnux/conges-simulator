import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["startDate", "endDate", "salary", "submitBtn"]

  validate(event) {
    const errors = []
    const start = this.startDateTarget.value
    const end_ = this.endDateTarget.value
    const salary = parseFloat(this.salaryTarget.value)

    if (!start) errors.push("La date de début est requise")
    if (!end_) errors.push("La date de fin est requise")

    if (start && end_ && new Date(end_) <= new Date(start)) {
      errors.push("La date de fin doit être postérieure à la date de début")
    }

    if (isNaN(salary) || salary < 200 || salary > 1200) {
      errors.push("Le salaire doit être compris entre 200 € et 1 200 €")
    }

    if (errors.length > 0) {
      event.preventDefault()
      alert(errors.join("\n"))
    }
  }
}