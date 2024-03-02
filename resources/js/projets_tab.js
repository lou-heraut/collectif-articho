fetch('/components/projets_tab.html')
    .then(response => response.text())
    .then(html => {
        document.getElementById('projets_tab').innerHTML = html;
    });
