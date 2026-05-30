(function () {
  var urlPattern = /https?:\/\/[^\s<>"'，。；：！？、]+/g;
  var skipTags = new Set(["A", "CODE", "PRE", "SCRIPT", "STYLE"]);

  function shouldSkip(node) {
    for (var el = node.parentElement; el; el = el.parentElement) {
      if (skipTags.has(el.tagName)) return true;
    }
    return false;
  }

  function trimTrailingPunctuation(url) {
    var match = url.match(/[),.;:!?，。；：！？]+$/);
    if (!match) return { url: url, trailing: "" };
    return {
      url: url.slice(0, -match[0].length),
      trailing: match[0]
    };
  }

  function linkLabel(url) {
    try {
      var parsed = new URL(url);
      var host = parsed.hostname.replace(/^www\./, "");
      var path = parsed.pathname && parsed.pathname !== "/" ? parsed.pathname : "";
      var label = host + path;
      return label.length > 42 ? label.slice(0, 39) + "..." : label;
    } catch (_error) {
      return url;
    }
  }

  function faviconUrl(url) {
    try {
      var parsed = new URL(url);
      return "https://www.google.com/s2/favicons?domain_url=" +
        encodeURIComponent(parsed.origin) +
        "&sz=64";
    } catch (_error) {
      return "https://www.google.com/s2/favicons?domain_url=" +
        encodeURIComponent(url) +
        "&sz=64";
    }
  }

  function createAutoLink(url) {
    var link = document.createElement("a");
    link.className = "auto-link";
    link.href = url;
    link.target = "_blank";
    link.rel = "noopener noreferrer";

    var icon = document.createElement("img");
    icon.className = "auto-link-icon";
    icon.src = faviconUrl(url);
    icon.alt = "";
    icon.loading = "lazy";

    link.appendChild(icon);
    link.appendChild(document.createTextNode(linkLabel(url)));
    return link;
  }

  function linkifyTextNode(textNode) {
    var text = textNode.nodeValue;
    urlPattern.lastIndex = 0;
    if (!urlPattern.test(text)) return;

    urlPattern.lastIndex = 0;
    var fragment = document.createDocumentFragment();
    var lastIndex = 0;
    var match;

    while ((match = urlPattern.exec(text)) !== null) {
      var rawUrl = match[0];
      var parts = trimTrailingPunctuation(rawUrl);

      fragment.appendChild(document.createTextNode(text.slice(lastIndex, match.index)));
      fragment.appendChild(createAutoLink(parts.url));
      if (parts.trailing) {
        fragment.appendChild(document.createTextNode(parts.trailing));
      }

      lastIndex = match.index + rawUrl.length;
    }

    fragment.appendChild(document.createTextNode(text.slice(lastIndex)));
    textNode.parentNode.replaceChild(fragment, textNode);
  }

  function run() {
    var root = document.querySelector(".thought-list");
    if (!root) return;

    var walker = document.createTreeWalker(
      root,
      NodeFilter.SHOW_TEXT,
      {
        acceptNode: function (node) {
          if (!node.nodeValue || !node.nodeValue.includes("http")) {
            return NodeFilter.FILTER_REJECT;
          }
          return shouldSkip(node) ? NodeFilter.FILTER_REJECT : NodeFilter.FILTER_ACCEPT;
        }
      }
    );
    var nodes = [];
    while (walker.nextNode()) nodes.push(walker.currentNode);
    nodes.forEach(linkifyTextNode);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", run);
  } else {
    run();
  }
})();
