document.addEventListener('DOMContentLoaded', function () {

    fetch('/components/ateliers_tab.html')
        .then(response => response.text())
        .then(html => {
            document.getElementById('ateliers_tab').innerHTML = html;

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
});

