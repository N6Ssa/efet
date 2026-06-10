/**
 * Анимации hero-секции.
 * Каждый элемент с data-anim можно настраивать через data-* атрибуты
 * или расширять здесь.
 */
(function () {
  var shapes = document.querySelectorAll('.efet-shape[data-anim], .efet-hero__logo-img[data-anim]');

  shapes.forEach(function (el, index) {
    if (!el.style.getPropertyValue('--float-duration')) {
      el.style.setProperty('--float-duration', 4 + (index % 3) + 's');
    }
    if (!el.style.getPropertyValue('--float-delay')) {
      el.style.setProperty('--float-delay', index * 0.35 + 's');
    }
  });

  document.querySelectorAll('.efet-hero__waves path[data-anim]').forEach(function (path, index) {
    path.style.setProperty('--wave-duration', 7 + index + 's');
    path.style.setProperty('--wave-delay', index * 0.5 + 's');
  });
})();
