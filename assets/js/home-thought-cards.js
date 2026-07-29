(function () {
  "use strict";

  var cards = Array.prototype.slice.call(
    document.querySelectorAll(".home-thought-card")
  );
  var reduceMotion = window.matchMedia(
    "(prefers-reduced-motion: reduce)"
  ).matches;

  function parts(card) {
    return {
      content: card.querySelector(".home-thought-content"),
      more: card.querySelector(".home-thought-read-more"),
      label: card.querySelector(".home-thought-read-more-label"),
    };
  }

  function setButton(card, expanded) {
    var elements = parts(card);
    if (!elements.more || !elements.label) return;

    elements.more.setAttribute("aria-expanded", String(expanded));
    elements.label.textContent = expanded ? "Less" : "More";
  }

  function updateMore(card) {
    if (card.classList.contains("is-expanded")) return;

    var elements = parts(card);
    if (!elements.content || !elements.more) return;

    elements.content.style.maxHeight = "";
    var overflowing =
      elements.content.scrollHeight > elements.content.clientHeight + 1;

    elements.content.dataset.collapsedHeight =
      elements.content.clientHeight + "px";
    card.classList.toggle("is-truncated", overflowing);
    elements.more.hidden = !overflowing;
    setButton(card, false);
  }

  function expand(card) {
    var elements = parts(card);
    if (!elements.content) return;

    var collapsedHeight = elements.content.getBoundingClientRect().height;
    elements.content.style.maxHeight = collapsedHeight + "px";
    card.classList.remove("is-truncated");
    card.classList.add("is-expanded");
    setButton(card, true);

    if (reduceMotion) {
      elements.content.style.maxHeight = "none";
      return;
    }

    requestAnimationFrame(function () {
      elements.content.style.maxHeight = elements.content.scrollHeight + "px";
    });
  }

  function collapse(card) {
    var elements = parts(card);
    if (!elements.content) return;

    if (reduceMotion) {
      card.classList.remove("is-expanded");
      elements.content.style.maxHeight = "";
      setButton(card, false);
      updateMore(card);
      return;
    }

    elements.content.style.maxHeight = elements.content.scrollHeight + "px";
    elements.content.getBoundingClientRect();
    card.classList.add("is-collapsing");

    requestAnimationFrame(function () {
      elements.content.style.maxHeight =
        elements.content.dataset.collapsedHeight;
    });
  }

  function toggle(card) {
    if (card.classList.contains("is-expanded")) {
      collapse(card);
    } else {
      expand(card);
    }
  }

  cards.forEach(function (card) {
    var elements = parts(card);
    if (!elements.more || !elements.content) return;

    elements.more.addEventListener("click", function () {
      toggle(card);
    });

    elements.content.addEventListener("transitionend", function (event) {
      if (
        event.propertyName === "max-height" &&
        card.classList.contains("is-collapsing")
      ) {
        card.classList.remove("is-collapsing");
        card.classList.remove("is-expanded");
        elements.content.style.maxHeight = "";
        setButton(card, false);
        updateMore(card);
      } else if (
        event.propertyName === "max-height" &&
        card.classList.contains("is-expanded")
      ) {
        elements.content.style.maxHeight = "none";
      }
    });
  });

  function updateAll() {
    cards.forEach(updateMore);
  }

  updateAll();

  if ("ResizeObserver" in window) {
    var observer = new ResizeObserver(updateAll);
    cards.forEach(function (card) {
      observer.observe(card);
    });
  } else {
    window.addEventListener("resize", updateAll);
  }

  if (document.fonts && document.fonts.ready) {
    document.fonts.ready.then(updateAll);
  }
})();
