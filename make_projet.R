
projets_drive_dir = "drive"
Projets_drive_path = list.files(projets_drive_dir, full.names=TRUE)

pages_dir = "pages"

# projets_amenagements
# projets_chantiers_participatifs
# projets_microarchitectures
# projets_signaletique
# projets
    

projets_dir = file.path(pages_dir, "projets")
projet_defautl_path = file.path(pages_dir, "default_projet.html")
projets_defautl_path = file.path(pages_dir, "default_projets.html")
projet_default = readLines(projet_defautl_path)
projets_default = readLines(projets_defautl_path)

projets_resource_dir = "resources/images/projets"

Projet_path = c()
Projet_img = c()
Projet_title = c()

for (projet_drive_path in Projets_drive_path) {
    projet = projet_default
    projet_name = tolower(gsub(" ", "_",
                               readLines(file.path(projet_drive_path,
                                                   "titre.txt"))))
    projet_path = paste0(file.path(projets_dir, projet_name), ".html")
    Projet_path = c(Projet_path, projet_path)
    
    projet_resource_dir = file.path(projets_resource_dir, projet_name)
    unlink(projet_resource_dir)
    dir.create(projet_resource_dir)
    
    title =
        paste0('<h1 class="text_center">',
               readLines(file.path(projet_drive_path, "titre.txt")),
               '</h1>')
    Projet_title = c(Projet_title, title)
    projet = gsub("[$]TITLE[$]", title, projet)
    
    subtitle =
        paste0('<h2 class="text_center">',
               stringr::str_to_sentence(readLines(file.path(projet_drive_path,
                                                            "soustitre.txt"))),
               '</h2>')
    projet = gsub("[$]SUBTITLE[$]", subtitle, projet)

    img_path = list.files(projet_drive_path,
                          pattern="[[:digit:]]+", full.names=TRUE)
    img = basename(img_path)
    file.copy(img_path, file.path(projet_resource_dir, img))
    main_img = paste0('<img src="/',
                      projet_resource_dir, '/',
                      img[1], '">')
    Projet_img = c(Projet_img, file.path(projet_resource_dir, img[1]))
    img = img[-1]
    projet = gsub("[$]MAIN_IMG[$]",  main_img, projet)
    
    infos = readLines(file.path(projet_drive_path, "info.txt"))
    for (i in 1:length(infos)) {
        info = infos[i]
        info_name = unlist(strsplit(info, ":"))[1]
        info_name = gsub("(^ )|( $)", "", info_name)
        info = unlist(strsplit(info, ":"))[2]
        info = gsub("(^ )|( $)", "", info)
        info = paste0('<div class="projet_info"><b>',
                      info_name,
                      '</b><span>',
                      info,
                      '</span></div>')
        infos[i] = info
    }
    infos = paste0("		    ", infos, collapse="\n")
    projet = gsub(".*[$]INFO[$]", infos, projet)
    
    p = paste0('<p>',
               readLines(file.path(projet_drive_path, "text.txt")),
               '</p>')
    p = paste0("	    ", p, collapse="\n")
    projet = gsub(".*[$]P[$]", p, projet)

    
    img = paste0('<div class="container_img"><img src="/',
                 projet_resource_dir, "/",
                 img, '"></div>')
    img = paste0("		", img, collapse="\n")
    projet = gsub(".*[$]IMG[$]", img, projet)

    writeLines(projet, projet_path)
}

projets = projets_default
projets_name = "projets"
projets_path = paste0(file.path(pages_dir, projets_name), ".html")

Projet =
    paste0(paste0('		<a class="projet_thumbnail" href="/', Projet_path, '">
		    <div class="overlay"><span>', Projet_title, '</span></div>
		    <img src="/', Projet_img, '">
		</a>'), collapse="\n\n")

projets = gsub(".*[$]PROJET[$]", Projet, projets)

writeLines(projets, projets_path)
