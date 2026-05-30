(function () {
  function run() {
    var items = document.getElementById("home-tag-cloud-items");
    if (!items) return;

    var tags = Array.prototype.slice.call(items.querySelectorAll(".home-tag-pill"));
    tags.sort(function (a, b) {
      var countDiff = Number(b.dataset.count || 0) - Number(a.dataset.count || 0);
      if (countDiff !== 0) return countDiff;
      return a.textContent.trim().localeCompare(b.textContent.trim());
    });
    tags.forEach(function (tag) {
      items.appendChild(tag);
    });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", run);
  } else {
    run();
  }
})();
