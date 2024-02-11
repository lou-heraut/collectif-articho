
function plusSlides(n, button) {
    const container = button.parentNode.parentNode;
    let slideIndex = parseInt(container.dataset.index);
    showSlides(slideIndex += n, button);
}

function showSlides(n, button) {
    const container = button.parentNode.parentNode;
    let i;
    const slides = container.getElementsByClassName("image");
    const dots = container.getElementsByClassName("dot");

    if (n > slides.length) {
        n = 1;
    }
    if (n < 1) {
        n = slides.length;
    }
    for (i = 0; i < slides.length; i++) {
        slides[i].style.display = "none";
    }
    for (i = 0; i < dots.length; i++) {
        dots[i].classList.remove("active");
    }
    slides[n - 1].style.display = "block";
    dots[n - 1].classList.add("active");

    container.dataset.index = n;
}
