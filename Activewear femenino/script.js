const form = document.querySelector("#signup-form");
const statusMessage = document.querySelector("#form-status");
const productButtons = document.querySelectorAll("[data-product]");
const favoriteSelect = document.querySelector("select[name='favorite']");
const productGrid = document.querySelector("#product-grid");
const carouselButtons = document.querySelectorAll(".carousel-button");
const featuresTrack = document.querySelector("#features-track");
const featureNavButtons = document.querySelectorAll(".feature-nav");

productButtons.forEach((button) => {
  button.addEventListener("click", () => {
    favoriteSelect.value = button.dataset.product;
    document.querySelector("#comunidad").scrollIntoView({ behavior: "smooth" });
  });
});

form.addEventListener("submit", (event) => {
  event.preventDefault();
  const data = new FormData(form);
  const name = data.get("name").toString().trim();
  statusMessage.textContent = `${name}, quedaste en la lista de lanzamiento.`;
  form.reset();
});

carouselButtons.forEach((button) => {
  button.addEventListener("click", () => {
    const direction = button.classList.contains("next") ? 1 : -1;
    const card = productGrid.querySelector(".product-card");
    const gap = parseFloat(getComputedStyle(productGrid).columnGap) || 0;
    productGrid.scrollBy({
      left: direction * (card.offsetWidth + gap),
      behavior: "smooth",
    });
  });
});

featureNavButtons.forEach((button) => {
  button.addEventListener("click", () => {
    const direction = button.classList.contains("next") ? 1 : -1;
    const card = featuresTrack.querySelector("article");
    featuresTrack.scrollBy({
      left: direction * card.offsetWidth,
      behavior: "smooth",
    });
  });
});
