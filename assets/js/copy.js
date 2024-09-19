const pad = (num) => num.toString().padStart(2, "0");

export default {
  mounted() {
    this.el.addEventListener("click", (ev) => {
      ev.preventDefault();
      let siblings = this.el.parentNode.children;
      let today = new Date();
      let text = `${siblings[0].innerText} ${pad(today.getUTCMonth() + 1)}/${pad(today.getUTCDate())}\n\n${siblings[1].innerText}\n\n<https://beabadooble.com>`;
      navigator.clipboard.writeText(text);

      let inner = this.el.children[0].children;

      inner[0].innerText = "COPIED!";
      this.el.classList.add("bg-green-200");
      this.el.classList.add("hover:bg-green-200");

      setTimeout(() => {
        inner[0].innerText = "COPY";
        this.el.classList.remove("bg-green-200");
        this.el.classList.remove("hover:bg-green-200");
      }, 900);
    })
  }
}
