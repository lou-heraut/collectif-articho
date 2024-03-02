fetch('/components/mobiliers_tab.html')
    .then(response => response.text())
    .then(html => {
        document.getElementById('mobiliers_tab').innerHTML = html;
    });
