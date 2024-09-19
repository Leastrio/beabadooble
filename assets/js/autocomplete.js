export default {
  mounted() {
    this.options = Array.from(this.el.options);
    this.el.innerHTML = '';

    datalist = this.el;
    options = this.options;

    for (let e of document.getElementsByTagName('input')) {
      function filterOptions() {
        datalist.innerHTML = '';
        if (e.value != "") {
          const search = e.value.toLowerCase();

          options
            .filter(option => option.value.toLowerCase().includes(search))
            .forEach(option => datalist.appendChild(option));
        }
      }

      e.addEventListener('input', debounce(filterOptions, 200))
    }
  }
}

function debounce(func, timeout) {
  let timer;
  return (...args) => {
    clearTimeout(timer);
    timer = setTimeout(() => { func.apply(this, args); }, timeout);
  }
}
