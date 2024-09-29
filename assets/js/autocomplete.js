export default {
  mounted() {
    this.handleEvent("session:autocomplete_data", ({data}) => {
      this.autocomplete_options = data;
    });

    window.addEventListener("input_focus", e => {
      this.list_el = document.createElement('ul')
      this.list_el.className = "absolute w-full mt-1 bg-white border border-gray-300 rounded-md shadow-lg max-h-60 overflow-y-auto z-10 list-none p-0"
      
      this.autocomplete_options.forEach(option => {
        const list_item = document.createElement('li')
        list_item.textContent = option;
        this.list_el.appendChild(list_item)
      })


      e.target.parentElement.appendChild(this.list_el)
    });

    window.addEventListener("input_blur", e => {
      /*if (this.list_el) {
        this.list_el.remove()
      }*/
    });

    /*this.options = Array.from(this.el.options);
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
    }*/
  }
}

function debounce(func, timeout) {
  let timer;
  return (...args) => {
    clearTimeout(timer);
    timer = setTimeout(() => { func.apply(this, args); }, timeout);
  }
}
