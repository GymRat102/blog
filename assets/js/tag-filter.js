(function () {
  function selectedTag() {
    var params = new URLSearchParams(window.location.search);
    var tag = params.get("tag");
    if (tag) return tag;

    if (window.location.hash.indexOf("#tag-") === 0) {
      return decodeURIComponent(window.location.hash.slice(5));
    }

    return "";
  }

  function run() {
    var tag = selectedTag();
    if (!tag) return;

    var sections = Array.prototype.slice.call(document.querySelectorAll(".tag-section"));
    var matched = false;

    sections.forEach(function (section) {
      var isMatch = section.getAttribute("data-tag") === tag;
      section.hidden = !isMatch;
      if (isMatch) {
        var sectionTitle = section.querySelector(".tag-section-title");
        if (sectionTitle) sectionTitle.style.display = "none";
      }
      matched = matched || isMatch;
    });

    if (!matched) {
      sections.forEach(function (section) {
        section.hidden = false;
      });
      return;
    }

    var title = document.getElementById("tag-page-title");
    if (title) title.textContent = tag;
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", run);
  } else {
    run();
  }
})();
