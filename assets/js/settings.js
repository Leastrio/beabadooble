import {Howler} from "../vendor/howler.core.min.js";

export default {
  mounted() {
    this.vol_slider = document.querySelector("#volume-slider");
    this.vol_span = document.querySelector("#volume-span");

    this.vol_slider.addEventListener('input', (evt) => {
      this.vol_span.innerText = evt.target.value + "%";
    })

    this.vol_slider.addEventListener('change', (evt) => {
      Howler.volume(evt.target.value / 100);
      this.save_settings();
    })
  },
  save_settings() {
    localStorage.setItem("settings", JSON.stringify({volume: this.vol_slider.valueAsNumber}))
  }
}
