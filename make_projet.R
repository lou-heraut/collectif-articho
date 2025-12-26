
drive_dir = "drive"
pages_dir = "pages"
resource_dir = file.path("resources", "images")

projet_defautl_path = file.path(pages_dir, "default_projet.html")
projets_defautl_path = file.path(pages_dir, "default_projets.html")
mobiliers_defautl_path = file.path(pages_dir, "default_mobiliers.html")

projet_default = readLines(projet_defautl_path)
projets_default = readLines(projets_defautl_path)
mobiliers_default = readLines(mobiliers_defautl_path)

Tab_drive_path = list.files(drive_dir, full.names=TRUE)

# to_link = function (str) {
#     tolower(gsub(" ", "_", gsub("à", "a", gsub("(é)|(è)", "e", str))))
# }
to_link = function(str) {
    gsub(" ", "_",
         tolower(
             iconv(str, "UTF-8", "ASCII//TRANSLIT")
         ), fixed=TRUE)
}




## TAB _______________________________________________________________
for (tab_drive_path in Tab_drive_path) {

    # tab_drive_path = Tab_drive_path[2]
    
    tab = gsub("[_]", " ",
               gsub("[[:digit:]]+[_]", "",
                    basename(tab_drive_path)))
    subTab_drive_path = list.files(tab_drive_path,
                                   full.names=TRUE)
    
    Folders_path = c()
    Folders_img = c()
    Folders_type = c()
    Folders_title = c()
    Folders_subtitle = c()
    
## SUBTAB ____________________________________________________________
    for (subtab_drive_path in subTab_drive_path) {

        # subtab_drive_path = subTab_drive_path[2]
        
        subtab = gsub("[_]", " ",
                      gsub("[[:digit:]]+[_]", "",
                           basename(subtab_drive_path)))

        Folders_drive_path =  list.files(subtab_drive_path,
                                         full.names=TRUE)

        folders_dir = file.path(pages_dir,
                               to_link(tab),
                               to_link(subtab))

        unlink(folders_dir, recursive=TRUE)
        dir.create(folders_dir, recursive=TRUE)


## MOBILIER ____________________________________________________________        
        if (subtab == "Ligne de mobilier") {

            
            Folders_img = c()
            Folders_nImg = c()
            Folders_prix = c()
            Folders_modality = c()
            Folders_dimensions = c()
            Folders_materiaux = c()
            Folders_title = c()
            
            for (folder_drive_path in Folders_drive_path) {

                # folder_drive_path = Folders_drive_path[1]
                
                # folder = folder_default
                folder_name = tolower(
                    gsub(" ", "_",
                         readLines(file.path(folder_drive_path,
                                             "titre.txt"))))

                folder_resource_dir = file.path(resource_dir,
                                                to_link(tab),
                                                to_link(subtab),
                                                folder_name)
                unlink(folder_resource_dir, recursive=TRUE)
                dir.create(folder_resource_dir, recursive=TRUE)
                

                title =
                    readLines(file.path(folder_drive_path, "titre.txt"))
                Folders_title = c(Folders_title, paste0("<h2>", title, "</h2>"))


                
                img_path = list.files(folder_drive_path,
                                      pattern="[[:digit:]]+",
                                      full.names=TRUE)
                img = basename(img_path)
                file.copy(img_path, file.path(folder_resource_dir, img))

                Folders_nImg = c(Folders_nImg,
                                 paste0('<span class="dot" onclick="showSlides(',
                                        2:length(img),
                                        ', this)"></span>', collapse="\n"))
                
                img = paste0(paste0('<img class="image active" src="/',
                                    folder_resource_dir, '/',
                                    img, '">'), collapse="\n")
                Folders_img = c(Folders_img, img)



                
                infos = readLines(file.path(folder_drive_path,
                                            "info.txt"))
                infos = infos[nchar(infos) > 0]

                prix = gsub("(.*[:][[:space:]]*)|([[:space:]]*$)",
                            "", infos[grepl("Prix", infos)])
                Folders_prix = c(Folders_prix, paste0("<h3>", prix, "</h3>"))
                
                # modality = gsub("(.*[:][[:space:]]*)|([[:space:]]*$)",
                #                 "", infos[grepl("Modalité", infos)])
                # Folders_modality = c(Folders_modality,
                #                     paste0('<span class="modality">',
                #                            modality, '</span>'))


                modality = gsub("(.*[:][[:space:]]*)|([[:space:]]*$)",
                                "", infos[grepl("Modalité", infos)])
                modality = unlist(strsplit(modality, "-"))
                modality = gsub("(^[[:space:]]*)|([[:space:]]*$)", "", modality)
                modality = paste0('<span class="modality">',
                                  paste0(modality, collapse="</br>"),
                                  "</span>")
                Folders_modality = c(Folders_modality, modality)


                
                dimensions = gsub("[:]", "",
                                  infos[grepl("Dimensions", infos)])
                dimensions = unlist(strsplit(dimensions, "-"))
                dimensions = gsub("(^[[:space:]]*)|([[:space:]]*$)", "", dimensions)
                dimensions[1] = paste0("<b>", dimensions[1], "</b>")
                dimensions = paste0("<span>",
                                    paste0(dimensions, collapse="</br>"),
                                    "</span>")
                Folders_dimensions = c(Folders_dimensions, dimensions)

                materiaux = gsub("[:]", "",
                                  infos[grepl("Matériaux", infos)])
                materiaux = unlist(strsplit(materiaux, "-"))
                materiaux = gsub("(^[[:space:]]*)|([[:space:]]*$)", "", materiaux)
                materiaux[1] = paste0("<b>", materiaux[1], "</b>")
                materiaux = paste0("<span>",
                                    paste0(materiaux, collapse="</br>"),
                                    "</span>")
                Folders_materiaux = c(Folders_materiaux, materiaux)
            }

            
            
            folders = mobiliers_default
            folders_path = file.path(pages_dir,
                                     to_link(tab),
                                     paste0(to_link(subtab),
                                            ".html"))

            # folders = gsub(".*[$]JS[$]",
            #                paste0('	<script src="/resources/js/',
            #                       to_link(tab),
            #                       '_tab.js"></script>\n',
            #                       '	<script src="/resources/js/gallery.js"></script>'),
            #                folders)
            folders = gsub(".*[$]JS[$]",
                           paste0('	</script>\n',
                                  '	<script src="/resources/js/gallery.js"></script>'),
                           folders)

            folders = gsub(".*[$]TITLE[$]",
                           paste0('	    <h1 class="text_center">',
                                  tab, '</h1>'),
                           folders)

            folders = gsub(".*[$]TABBAR[$]",
                           paste0('	    <div class="tab_bar" id="',
                                  to_link(tab), '_tab"></div>'),
                           folders)

            folders = gsub(".*[$]CSS[$]",
                           paste0('	<link rel="stylesheet" href="/resources/css/',
                                  to_link(tab), '.css">'),
                           folders)

            
            Folders =
                paste0(
                    paste0(
                        '		<div class="mobilier">
                    <div class="text-container">
		    <div class="bunch_title">',
                    Folders_title,
                    # Folders_prix,
                    '<a id="commander" href="/pages/contact.html" onclick="selectTab(\'header_tab-contact\')">
			    <span class="material-icons-outlined">shopping_bag</span>
			    <h4>Prix sur demande</h4>
			</a>
		    </div>',
                    Folders_modality,
                    ' <div class="bunch_info">',
                    Folders_dimensions,
                    Folders_materiaux,
                    '</div>',
                    '</div>',
                    '<div class="gallery-container" data-index="1">',
                    Folders_img,
                    
                    '<div class="navigation">
			    <button class="nav-button material-icons-outlined" onclick="plusSlides(-1, this)" style="transform: rotate(90deg);">expand_circle_down</button>
			    <span class="dot active" onclick="showSlides(1, this)"></span>',
                    Folders_nImg,
                    '<button class="nav-button material-icons-outlined" onclick="plusSlides(1, this)" style="transform: rotate(-90deg);">expand_circle_down</button>
			</div>',
                    '</div>\n</div>'),
                    collapse="\n\n")



            folders = gsub(".*[$]PROJET[$]", Folders, folders)

            writeLines(folders, folders_path)

            # Folders_path = c(Folders_path, Folder_path)
            # Folders_img = c(Folders_img, Folder_img)
            # Folders_type = c(Folders_type, Folder_type)
            # Folders_title = c(Folders_title, Folder_title)
            # Folders_subtitle = c(Folders_subtitle, Folder_subtitle)

            
            
## PROJET ____________________________________________________________            
        } else {
            Folder_path = c()
            Folder_img = c()
            Folder_type = c()
            Folder_title = c()
            Folder_subtitle = c()
            
            for (folder_drive_path in Folders_drive_path) {
                folder = projet_default
                folder_name = tolower(
                    gsub(" ", "_",
                         readLines(file.path(folder_drive_path,
                                             "titre.txt"))))
                folder_path = paste0(file.path(folders_dir,
                                               folder_name),
                                     ".html")
                Folder_path = c(Folder_path, folder_path)

                folder_resource_dir = file.path(resource_dir,
                                                to_link(tab),
                                                to_link(subtab),
                                                folder_name)
                unlink(folder_resource_dir, recursive=TRUE)
                dir.create(folder_resource_dir, recursive=TRUE)
                
                Folder_type = c(Folder_type, subtab)

                title_text =
                    readLines(file.path(folder_drive_path, "titre.txt"))
                title =
                    paste0('<h1 class="text_center text_compact">',
                           title_text, '</h1>')
                Folder_title = c(Folder_title, title_text)
                folder = gsub("[$]TITLE[$]", title, folder)

                subtitle_text =
                    readLines(file.path(folder_drive_path,
                                        "soustitre.txt"))
                subtitle =
                    paste0('<h2 class="text_center text_compact">',
                           subtitle_text, '</h2>')
                Folder_subtitle = c(Folder_subtitle, subtitle_text)
                folder = gsub("[$]SUBTITLE[$]", subtitle, folder)
                
                img_path = list.files(folder_drive_path,
                                      pattern="[[:digit:]]+",
                                      full.names=TRUE)
                img = basename(img_path)
                file.copy(img_path, file.path(folder_resource_dir, img))

                main_img = paste0('<img src="/',
                                  folder_resource_dir, '/',
                                  img[1], '">')
                Folder_img = c(Folder_img,
                               file.path(folder_resource_dir, img[1]))
                img = img[-1]
                folder = gsub("[$]MAIN_IMG[$]",  main_img, folder)
                
                infos = readLines(file.path(folder_drive_path,
                                            "info.txt"))
                infos = infos[nchar(infos) > 0]
                
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
                infos = paste0("		    ", infos,
                               collapse="\n")
                folder = gsub(".*[$]INFO[$]", infos, folder)


                text = readLines(file.path(folder_drive_path,
                                           "text.txt"))
                text = text[nchar(text) > 0]
                p = paste0('<p>', text, '</p>')
                p = paste0("	    ", p, collapse="\n")
                folder = gsub(".*[$]P[$]", p, folder)
                
                img = paste0('<div class="container_img"><img src="/',
                             folder_resource_dir, "/",
                             img, '"></div>')
                img = paste0("		", img, collapse="\n")
                folder = gsub(".*[$]IMG[$]", img, folder)

                writeLines(folder, folder_path)
            }


            folders = projets_default
            folders_path = file.path(pages_dir,
                                     to_link(tab),
                                     paste0(to_link(subtab),
                                            ".html"))

            # folders = gsub(".*[$]JS[$]",
            #                paste0('	<script src="/resources/js/',
            #                       to_link(tab), '_tab.js"></script>'),
            #                folders)
            folders = gsub(".*[$]JS[$]",
                           paste0(''),
                           folders)
            
            folders = gsub(".*[$]TITLE[$]",
                           paste0('	    <h1 class="text_center">',
                                  tab, '</h1>'),
                           folders)

            folders = gsub(".*[$]TABBAR[$]",
                           paste0('	    <div class="tab_bar" id="',
                                  to_link(tab), '_tab"></div>'),
                           folders)
            
            folders = gsub(".*[$]CSS[$]", "", folders)
            
            Folder =
                paste0(paste0('		<a class="projet_thumbnail" href="/', Folder_path, '">
		    <div class="overlay"><h2>', Folder_type, '</h2><h3>', Folder_title, '</h3><h4>', Folder_subtitle, '</h4></div>
		    <img src="/', Folder_img, '">
		</a>'), collapse="\n\n")

            folders = gsub(".*[$]PROJET[$]", Folder, folders)

            writeLines(folders, folders_path)

            Folders_path = c(Folders_path, Folder_path)
            Folders_img = c(Folders_img, Folder_img)
            Folders_type = c(Folders_type, Folder_type)
            Folders_title = c(Folders_title, Folder_title)
            Folders_subtitle = c(Folders_subtitle, Folder_subtitle)
        }
    }


    if (!(tab %in% c("Mobiliers", "Ateliers"))) {

        folders = projets_default
        folders_path = file.path(pages_dir,
                                 paste0(to_link(tab),
                                        ".html"))
        folders = gsub(".*[$]JS[$]",
                       paste0('	<script src="/resources/js/',
                              to_link(tab), '_tab.js"></script>'),
                       folders)
        folders = gsub(".*[$]CSS[$]", "", folders)
        folders = gsub(".*[$]TITLE[$]",
                       paste0('	    <h1 class="text_center">',
                              tab, '</h1>'),
                       folders)
        folders = gsub(".*[$]TABBAR[$]",
                       paste0('	    <div class="tab_bar" id="',
                              to_link(tab), '_tab"></div>'),
                       folders)
        Folder =
            paste0(paste0('		<a class="projet_thumbnail" href="/', Folders_path, '">
		    <div class="overlay"><h2>', Folders_type, '</h2><h3>', Folders_title, '</h3><h4>', Folders_subtitle, '</h4></div>
		    <img src="/', Folders_img, '">
		</a>'), collapse="\n\n")
        folders = gsub(".*[$]PROJET[$]", Folder, folders)

        writeLines(folders, folders_path)
    }
}













# <div class="mobilier">
#     <div class="bunch_title">
# 	<h2>Table haute</h2>
# 	<h3>950 €</h3>
# 	<a id="commander" href="/pages/contact.html" onclick="selectTab('header_tab-contact')">
# 	    <span class="material-icons-outlined">shopping_bag</span>
# 	    <h4>Commander</h4>
# 	</a>
#     </div>
#     <span class="higher-line">Sur commande : 1 pièce minimum</span>
#     <div class="bunch_info">
# 	<span><b>Dimension</b></br>
# 	    - Longueur 140 cm</br>
# 	    - Largeur 70 cm</br>
# 	    - Hauteur 72 cm</br></span>
# 	<span><b>Matériaux</b></br>
# 	    Issus du réemploi</br>
# 	    Contreplaqué de bouleau filmé noir</span>
#     </div>
#     <div class="gallery-container">
# 	<img class="image active" src="/resources/images/mobiliers/ligne_de_mobilier/table_haute/1.JPG">
# 	<img class="image" src="/resources/images/mobiliers/ligne_de_mobilier/table_haute/2.JPG">
# 	<img class="image" src="/resources/images/mobiliers/ligne_de_mobilier/table_haute/3.JPG">

# 	<div class="navigation">
# 	    <button class="nav-button material-icons-outlined" onclick="plusSlides(-1)"
# 		    style="transform: rotate(90deg);">expand_circle_down</button>
# 	    <span class="dot active" onclick="currentSlide(1)"></span>
# 	    <span class="dot" onclick="currentSlide(2)"></span>
# 	    <span class="dot" onclick="currentSlide(3)"></span>
# 	    <button class="nav-button material-icons-outlined" onclick="plusSlides(1)"
# 	    style="transform: rotate(-90deg);">expand_circle_down</button>
# 	</div>
#     </div>
# </div>






