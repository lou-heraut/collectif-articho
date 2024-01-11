document.addEventListener('DOMContentLoaded', function () {
   fetch('../../components/header.html')
        .then(response => response.text())
        .then(html => {
            document.getElementById('header').innerHTML = html;

            var selectedTabIdsJson = localStorage.getItem('selectedTabId');
            if (selectedTabIdsJson) {
                var selectedTabIds = JSON.parse(selectedTabIdsJson);

                selectedTabIds.forEach(function (tabId) {
                    var selectedTab = document.getElementById(tabId);
                    if (selectedTab) {
                        selectedTab.classList.add('selected');
                    }
                });
            }
        });
    
   fetch('../../components/projets_tab.html')
        .then(response => response.text())
        .then(html => {
            document.getElementById('projets_tab').innerHTML = html;

            var selectedTabIdsJson = localStorage.getItem('selectedTabId');
            if (selectedTabIdsJson) {
                var selectedTabIds = JSON.parse(selectedTabIdsJson);

                selectedTabIds.forEach(function (tabId) {
                    var selectedTab = document.getElementById(tabId);
                    if (selectedTab) {
                        selectedTab.classList.add('selected');
                    }
                });
            }
        });
    
    fetch('../../components/footer.html')
        .then(response => response.text())
        .then(html => {
            document.getElementById('footer').innerHTML = html;
        });
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


function selectTab(selectedTabIds) {
    if (!Array.isArray(selectedTabIds)) {
        selectedTabIds = [selectedTabIds];
    }
    localStorage.setItem('selectedTabId', JSON.stringify(selectedTabIds));
    
    selectedTabIds.forEach(function (tabId) {
        var tab = document.getElementById(tabId);
        if (tab) {
	    var tabs = document.querySelectorAll('a.tab, a.subtab');
            tabs.forEach(function (t) {
		if (!selectedTabIds.includes(t.id)) {
                    t.classList.remove('selected');
		}
	    });
            tab.classList.add('selected');
        }
    });
}


function deselectTab() {
    var tab = $('a.selected');
    tab.removeClass('selected');
    localStorage.removeItem('selectedTabId')
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
