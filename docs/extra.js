/* use pkgdown::init_site() to apply changes made to this file */

function updateExternalLinks() {
  for (const link of document.getElementsByClassName('external-link')) {
    link.target = '_blank';
  };
}

document.addEventListener('DOMContentLoaded', updateExternalLinks, false);
