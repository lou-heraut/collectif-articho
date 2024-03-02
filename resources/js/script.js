fetch('/components/header.html')
    .then(response => response.text())
    .then(html => {
        document.getElementById('header').innerHTML = html;
    });

fetch('/components/footer.html')
    .then(response => response.text())
    .then(html => {
        document.getElementById('footer').innerHTML = html;
    });




function showMenu(menuId) {
    var menu = document.getElementById(menuId);
    if (menu) {
        menu.style.display = 'block';
    }
}

function hideMenu(menuId) {
    var menu = document.getElementById(menuId);
    if (menu) {
        menu.style.display = 'none';
    }
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


document.addEventListener('DOMContentLoaded', function() {
    function checkURL() {

	var url = window.location.href;
	var path = new URL(url).pathname;
	var page = path.split('/').pop().replace('.html', '');
	
	if (page === "projets") {
	    var IDs = ['header_tab-projets', 'projets_subtab-projets']
	} else if (page === "amenagements") {
	    var IDs = ['header_tab-projets', 'header_subtab-amenagements', 'projets_subtab-amenagements']
	} else if (page === "microarchitectures") {
	    var IDs = ['header_tab-projets', 'header_subtab-microarchitectures', 'projets_subtab-microarchitectures']
	} else if (page === "signaletiques") {
	    var IDs = ['header_tab-projets', 'header_subtab-signaletiques', 'projets_subtab-signaletique']
	} else if (page === "chantiers_participatifs") {
	    var IDs = ['header_tab-projets', 'header_subtab-chantiers_participatifs', 'projets_subtab-chantiers_participatifs']

	} else if (page === "mobiliers") {
	    var IDs = ['header_tab-mobiliers']
	} else if (page === "agencements") {
	    var IDs = ['header_tab-mobiliers', 'header_subtab-agencements', 'mobiliers_subtab-agencements']
	} else if (page === "ligne_de_mobilier") {
	    var IDs = ['header_tab-mobiliers', 'header_subtab-ligne_de_mobilier', 'mobiliers_subtab-ligne_de_mobilier']

	} else if (page === "ateliers") {
	    var IDs = ['header_tab-ateliers']
	} else if (page === "ateliers_sur-mesures") {
	    var IDs = ['header_tab-ateliers', 'header_subtab-ateliers_sur-mesures', 'ateliers_subtab-ateliers_sur-mesures']
	} else if (page === "notre_offre") {
	    var IDs = ['header_tab-ateliers', 'header_subtab-notre_offre', 'ateliers_subtab-notre_offre']

	} else if (page === "contact") {
	    var IDs = ['header_tab-contact']

	} else {
	    var IDs = null
	}

	$('a.selected').removeClass('selected');
	if (IDs) {
	    IDs.forEach(function (id) {
		$("#" + id)[0].classList.add('selected'); 
	    });
	}
    }

    window.addEventListener('hashchange', checkURL);
    window.addEventListener('popstate', checkURL);
    window.addEventListener('load', checkURL);
});
