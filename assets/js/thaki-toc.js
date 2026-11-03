/*
 * "On this page" for posts — the same pattern as the thakicloud.com Insights articles:
 * tick marks at the right edge (the current section's tick is longer and darker), and the
 * full list floats out on hover or keyboard focus. Keeps the right column free for the ad.
 * The links themselves are server-rendered by _includes/toc.html.
 */
(function () {
  'use strict';

  function init() {
    var nav = document.querySelector('.thaki-toc');
    if (!nav) return;
    var links = Array.prototype.slice.call(nav.querySelectorAll('.thaki-toc__list a'));
    var sections = links.map(function (link) {
      return document.getElementById(link.getAttribute('href').slice(1));
    });
    if (links.length < 2) return;

    var ticks = nav.querySelector('.thaki-toc__ticks');
    var tickItems = links.map(function (link, i) {
      var li = document.createElement('li');
      var button = document.createElement('button');
      button.type = 'button';
      button.tabIndex = -1;
      button.addEventListener('click', function () {
        if (sections[i]) sections[i].scrollIntoView({ behavior: 'smooth', block: 'start' });
      });
      li.appendChild(button);
      ticks.appendChild(li);
      return li;
    });
    // The theme's SmoothScroll stops 20px from the top, under the fixed site nav. Handle these
    // links here so the jump honours the headings' scroll-margin-top instead.
    links.forEach(function (link, i) {
      link.addEventListener('click', function (e) {
        if (!sections[i]) return;
        e.preventDefault();
        e.stopPropagation();
        sections[i].scrollIntoView({ behavior: 'smooth', block: 'start' });
        history.pushState(null, '', link.hash);
      });
    });
    nav.classList.add('is-ready');

    var active = -1;
    function update() {
      var current = 0;
      for (var i = 0; i < sections.length; i++) {
        if (!sections[i]) continue;
        if (sections[i].getBoundingClientRect().top <= 140) current = i;
        else break;
      }
      if (current === active) return;
      if (active >= 0) {
        tickItems[active].classList.remove('is-active');
        links[active].parentNode.classList.remove('is-active');
      }
      tickItems[current].classList.add('is-active');
      links[current].parentNode.classList.add('is-active');
      active = current;
    }
    update();
    window.addEventListener('scroll', update, { passive: true });
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
  else init();
})();
