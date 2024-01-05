document.addEventListener('DOMContentLoaded', function () {
    fetch('../../components/header.html')
        .then(response => response.text())
        .then(html => {
            document.getElementById('header').innerHTML = html;
        });
    fetch('../../components/footer.html')
        .then(response => response.text())
        .then(html => {
            document.getElementById('footer').innerHTML = html;
        });
});


function selectButton(selectedButton) {
    var buttons = selectedButton.parentNode.querySelectorAll('button');
    buttons.forEach(function (button) {
	button.classList.remove('selected');
    });
    selectedButton.classList.add('selected');
}

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
