document.addEventListener('DOMContentLoaded', function () {
    fetch('../../components/header.html')
        .then(response => response.text())
        .then(html => {
            document.getElementById('header').innerHTML = html;
            var selectedTabId = localStorage.getItem('selectedTabId');
            if (selectedTabId) {
                var selectedTab = document.getElementById(selectedTabId);
                if (selectedTab) {
                    selectedTab.classList.add('selected');
                }
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

// function selectTab(selectedTabId) {
//     selectedTab = document.getElementById(selectedTabId);
//     var tabs = selectedTab.parentNode.querySelectorAll('a');
//     tabs.forEach(function (tab) {
//         tab.classList.remove('selected');
//     });
//     selectedTab.classList.add('selected');

//     console.log(selectedTab);
    
//     localStorage.setItem('selectedTabId', selectedTab.id);
// }


function selectTab(selectedTabIds) {
    selectedTabIds.forEach(function (tabId) {
        var tab = document.getElementById(tabId);
        if (tab) {
            var tabs = tab.parentNode.querySelectorAll('a');
            tabs.forEach(function (t) {

		console.log(selectedTabIds);
		console.log(t.id);
		console.log("");
		if (!selectedTabIds.includes(t.id)) {
                    t.classList.remove('selected');
		}
	    });
            tab.classList.add('selected');
            
            console.log(tab);
            
            localStorage.setItem('selectedTabId', tab.id);
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
