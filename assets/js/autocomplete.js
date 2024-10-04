export default {
  mounted() {
    this.list_el = document.createElement('ul');
    this.list_el.className = "absolute z-10 w-60 md:w-full mt-1 bg-white border border-gray-300 rounded-md shadow-lg max-h-60 overflow-auto";

    this.handleEvent("session:autocomplete_data", ({data}) => {
      this.autocomplete_options = data;
    });

    window.addEventListener("input_focus", e => {
      if (this.list_el.innerHTML !== '') {
        autocomplete_input.bind(this)(e)
        e.target.parentElement.appendChild(this.list_el)
      }
    });

    window.addEventListener("input_blur", e => {
      setTimeout(() => {
        this.list_el.remove();
      }, 150);
    });

    for (let e of document.getElementsByName('guess-input')) {
      e.addEventListener('input', debounce(autocomplete_input.bind(this), 200))
    }
  }
}

function autocomplete_input(e) {
  this.list_el.innerHTML = '';
  if (e.target.value != "") {
    const search = e.target.value.toLowerCase();

    this.autocomplete_options
      .filter(option => option.toLowerCase().includes(search))
      .forEach(option => {
        const list_item = document.createElement('li')
        list_item.textContent = option;
        list_item.className = "px-4 py-2 hover:bg-gray-100 cursor-pointer font-[RobotoMono] text-gray-800";

        list_item.onclick = () => {
          e.target.value = option;
          this.list_el.remove();
        }
        this.list_el.appendChild(list_item)
      });
  }

  if (this.list_el.innerHTML === '') {
    this.list_el.remove()
  } else if (!e.target.parentElement.contains(this.list_el)) {
    e.target.parentElement.appendChild(this.list_el)
  }
}


function debounce(func, timeout) {
  let timer;
  return (...args) => {
    clearTimeout(timer);
    timer = setTimeout(() => { func.apply(this, args); }, timeout);
  }
}
