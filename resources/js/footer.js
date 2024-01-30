document.addEventListener('DOMContentLoaded', function () {
    fetch('/components/footer.html')
        .then(response => response.text())
        .then(html => {
            document.getElementById('footer').innerHTML = html;
        });
});


function changeImage(img, suffix) {	     
    var originalSrc = img.src;
    var dotIndex = originalSrc.lastIndexOf('.');
    var path = originalSrc.substring(0, dotIndex);
    var extension = originalSrc.substring(dotIndex);
    img.src = path + suffix + extension;
}
function restoreImage(img, suffix) {
    img.src = img.src.replace(suffix, ''); 
}
