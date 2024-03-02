fetch('/components/ateliers_tab.html')
    .then(response => response.text())
    .then(html => {
        document.getElementById('ateliers_tab').innerHTML = html;
    });
