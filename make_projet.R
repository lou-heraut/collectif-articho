
drive_dir = "drive"
pages_dir = "pages"
resource_dir = file.path("resources", "images")
projet_defautl_path = file.path(pages_dir, "default_projet.html")
projets_defautl_path = file.path(pages_dir, "default_projets.html")
projet_default = readLines(projet_defautl_path)
projets_default = readLines(projets_defautl_path)

Tab_drive_path = list.files(drive_dir, full.names=TRUE)

to_link = function (str) {
    tolower(gsub(" ", "_", gsub("à", "a", gsub("(é)|(è)", "e", str))))
}


## TAB _______________________________________________________________
for (tab_drive_path in Tab_drive_path) {
    tab = gsub("[_]", " ",
               gsub("[[:digit:]]+[_]", "",
                    basename(tab_drive_path)))
    subTab_drive_path = list.files(tab_drive_path,
                                   full.names=TRUE)

    
## SUBTAB ____________________________________________________________
    for (subtab_drive_path in subTab_drive_path) {
        subtab = gsub("[_]", " ",
                      gsub("[[:digit:]]+[_]", "",
                           basename(subtab_drive_path)))
        Projets_drive_path =  list.files(subtab_drive_path,
                                         full.names=TRUE)

        projets_dir = file.path(pages_dir,
                               to_link(tab),
                               to_link(subtab))
        unlink(projets_dir, recursive=TRUE)
        dir.create(projets_dir, recursive=TRUE)
        
        
## PROJET ____________________________________________________________
        Projet_path = c()
        Projet_img = c()
        Projet_type = c()
        Projet_title = c()
        Projet_subtitle = c()
        
        for (projet_drive_path in Projets_drive_path) {
            projet = projet_default
            projet_name = tolower(
                gsub(" ", "_",
                     readLines(file.path(projet_drive_path,
                                         "titre.txt"))))
            projet_path = paste0(file.path(projets_dir, projet_name), ".html")
            Projet_path = c(Projet_path, projet_path)

            projet_resource_dir = file.path(resource_dir,
                                            to_link(tab),
                                            to_link(subtab),
                                            projet_name)
            unlink(projet_resource_dir, recursive=TRUE)
            dir.create(projet_resource_dir, recursive=TRUE)
            

            Projet_type = c(Projet_type, subtab)
            
            title_text =
                readLines(file.path(projet_drive_path, "titre.txt"))
            title =
                paste0('<h1 class="text_center text_compact">',
                       title_text, '</h1>')
            Projet_title = c(Projet_title, title_text)
            projet = gsub("[$]TITLE[$]", title, projet)

            subtitle_text =
                stringr::str_to_sentence(readLines(
                             file.path(projet_drive_path,
                                       "soustitre.txt")))
            subtitle =
                paste0('<h2 class="text_center text_compact">',
                       subtitle_text, '</h2>')
            Projet_subtitle = c(Projet_subtitle, subtitle_text)
            projet = gsub("[$]SUBTITLE[$]", subtitle, projet)

            img_path = list.files(projet_drive_path,
                                  pattern="[[:digit:]]+", full.names=TRUE)
            img = basename(img_path)
            file.copy(img_path, file.path(projet_resource_dir, img))
            main_img = paste0('<img src="/',
                              projet_resource_dir, '/',
                              img[1], '">')
            Projet_img = c(Projet_img,
                           file.path(projet_resource_dir, img[1]))
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
        projets_path = file.path(pages_dir,
                                 to_link(tab),
                                 paste0(to_link(subtab),
                                        ".html"))

        Projet =
            paste0(paste0('		<a class="projet_thumbnail" href="/', Projet_path, '">
		    <div class="overlay"><h2>', Projet_type, '</h2><h3>', Projet_title, '</h3><h4>', Projet_subtitle, '</h4></div>
		    <img src="/', Projet_img, '">
		</a>'), collapse="\n\n")

        projets = gsub(".*[$]PROJET[$]", Projet, projets)

        writeLines(projets, projets_path)

    }
}


















