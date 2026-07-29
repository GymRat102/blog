(function () {
  "use strict";

  var dialog = document.querySelector("#thought-lightbox");
  if (!dialog) return;

  var track = dialog.querySelector(".thought-lightbox-track");
  var closeButton = dialog.querySelector(".thought-lightbox-close");
  var previousButton = dialog.querySelector(".thought-lightbox-prev");
  var nextButton = dialog.querySelector(".thought-lightbox-next");
  var counter = dialog.querySelector(".thought-lightbox-counter");
  var sourceButton = null;
  var currentIndex = 0;
  var itemCount = 0;
  var scrollFrame = null;

  function updateControls() {
    previousButton.disabled = currentIndex === 0;
    nextButton.disabled = currentIndex === itemCount - 1;
    counter.textContent = itemCount ? currentIndex + 1 + " / " + itemCount : "";
  }

  function goTo(index, behavior) {
    currentIndex = Math.max(0, Math.min(index, itemCount - 1));
    track.scrollTo({
      left: currentIndex * track.clientWidth,
      behavior: behavior || "smooth",
    });
    updateControls();
  }

  function renderGallery(gallery) {
    var thumbnails = Array.prototype.slice.call(
      gallery.querySelectorAll(".home-thought-thumbnail-button")
    );

    track.innerHTML = "";
    itemCount = thumbnails.length;

    thumbnails.forEach(function (thumbnail) {
      var slide = document.createElement("figure");
      var image = document.createElement("img");

      slide.className = "thought-lightbox-slide";
      image.src = thumbnail.dataset.gallerySrc;
      image.alt = thumbnail.dataset.galleryAlt || "";
      image.decoding = "async";
      slide.appendChild(image);
      track.appendChild(slide);
    });
  }

  function openGallery(button) {
    var gallery = button.closest(".home-thought-gallery");
    var thumbnails = Array.prototype.slice.call(
      gallery.querySelectorAll(".home-thought-thumbnail-button")
    );

    sourceButton = button;
    renderGallery(gallery);
    currentIndex = thumbnails.indexOf(button);

    if (typeof dialog.showModal === "function") {
      dialog.showModal();
    } else {
      dialog.setAttribute("open", "");
    }

    document.body.classList.add("has-thought-lightbox");
    requestAnimationFrame(function () {
      goTo(currentIndex, "auto");
    });
  }

  function cleanup() {
    document.body.classList.remove("has-thought-lightbox");
    track.innerHTML = "";
    itemCount = 0;

    if (sourceButton) {
      sourceButton.focus();
      sourceButton = null;
    }
  }

  function closeGallery() {
    if (typeof dialog.close === "function") {
      dialog.close();
    } else {
      dialog.removeAttribute("open");
      cleanup();
    }
  }

  document
    .querySelectorAll(".home-thought-thumbnail-button")
    .forEach(function (button) {
      button.addEventListener("click", function () {
        openGallery(button);
      });
    });

  closeButton.addEventListener("click", closeGallery);
  previousButton.addEventListener("click", function () {
    goTo(currentIndex - 1);
  });
  nextButton.addEventListener("click", function () {
    goTo(currentIndex + 1);
  });

  dialog.addEventListener("click", function (event) {
    if (
      event.target === dialog ||
      event.target.classList.contains("thought-lightbox-slide")
    ) {
      closeGallery();
    }
  });

  dialog.addEventListener("keydown", function (event) {
    if (event.key === "ArrowLeft") {
      event.preventDefault();
      goTo(currentIndex - 1);
    } else if (event.key === "ArrowRight") {
      event.preventDefault();
      goTo(currentIndex + 1);
    } else if (event.key === "Escape" && typeof dialog.close !== "function") {
      event.preventDefault();
      closeGallery();
    }
  });

  dialog.addEventListener("close", cleanup);

  track.addEventListener("scroll", function () {
    if (scrollFrame) cancelAnimationFrame(scrollFrame);
    scrollFrame = requestAnimationFrame(function () {
      if (!track.clientWidth) return;
      currentIndex = Math.round(track.scrollLeft / track.clientWidth);
      updateControls();
    });
  });

  window.addEventListener("resize", function () {
    if (dialog.hasAttribute("open")) goTo(currentIndex, "auto");
  });
})();
