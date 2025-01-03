export const location = $state({path: window.location.pathname});

window.addEventListener("popstate", () => {
  location.path = window.location.pathname;
});

export function route(node) {
  const handleClick = (event) => {
    event.preventDefault();
    window.history.pushState("", "", node.href);
    location.path = window.location.pathname;
  }

  node.addEventListener("click", handleClick);

  return {
    destroy() {
      node.removeEventListener("click", handleClick);
    }
  }
}
