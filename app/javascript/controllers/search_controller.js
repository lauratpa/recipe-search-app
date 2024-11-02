import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "results", "form" ]

  connect() {
    console.log("Connected!")
  }

  search() {
    const csrfToken = document.querySelector("[name='csrf-token']").content

    fetch(this.formTarget.action, {
      method: this.formTarget.method,
      headers: { "X-CSRF-Token": csrfToken },
      body: new FormData(this.formTarget)
    })
    .then(response => response.text())
    .then(data => this.resultsTarget.innerHTML = data) 
  }
}
  
