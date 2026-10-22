let script = document.createElement("script");
script.src = "//js.hs-scripts.com/22554992.js";
document.body.append(script);

let script2 = document.createElement("script");
script2.src = "https://plausible.io/js/pa-POUVzq5eFpnqXBI7aYhWG.js";
script2.async = true;
document.body.append(script2);

window.plausible =
  window.plausible ||
  function () {
    (window.plausible.q = window.plausible.q || []).push(arguments);
  };
window.plausible.init =
  window.plausible.init ||
  function (i) {
    window.plausible.o = i || {};
  };
window.plausible.init();
