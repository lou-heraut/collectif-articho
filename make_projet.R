
drive_dir = "drive"
pages_dir = "pages"
resource_dir = file.path("resources", "images")
folder_defautl_path = file.path(pages_dir, "default_folder.html")
folders_defautl_path = file.path(pages_dir, "default_folders.html")
folder_default = readLines(folder_defautl_path)
folders_default = readLines(folders_defautl_path)

Tab_drive_path = list.files(drive_dir, full.names=TRUE)

to_link = function (str) {
    tolower(gsub(" ", "_", gsub("à", "a", gsub("(é)|(è)", "e", str))))
}


exception = "Ligne de mobilier"


## TAB _______________________________________________________________
for (tab_drive_path in Tab_drive_path) {
    tab = gsub("[_]", " ",
               gsub("[[:digit:]]+[_]", "",
                    basename(tab_drive_path)))
    subTab_drive_path = list.files(tab_drive_path,
                                   full.names=TRUE)
    
    # subTab_drive_path =
    #     subTab_drive_path[!grepl(paste0("(",
    #                                     paste0(exception, collapse=")|("),
    #                                     ")"), subTab_drive_path)]

    Folders_path = c()
    Folders_img = c()
    Folders_type = c()
    Folders_title = c()
    Folders_subtitle = c()
    
## SUBTAB ____________________________________________________________
    for (subtab_drive_path in subTab_drive_path) {
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
        
        
## PROJET ____________________________________________________________
        Folder_path = c()
        Folder_img = c()
        Folder_type = c()
        Folder_title = c()
        Folder_subtitle = c()
        
        for (folder_drive_path in Folders_drive_path) {
            folder = folder_default
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

            if (subtab != "Ligne de mobilier") {
                subtitle_text =
                    stringr::str_to_sentence(readLines(
                                 file.path(folder_drive_path,
                                           "soustitre.txt")))
                subtitle =
                    paste0('<h2 class="text_center text_compact">',
                           subtitle_text, '</h2>')
                Folder_subtitle = c(Folder_subtitle, subtitle_text)
                folder = gsub("[$]SUBTITLE[$]", subtitle, folder)
            }

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

            if (subtab != "Ligne de mobilier") {
                p = paste0('<p>',
                           readLines(file.path(folder_drive_path,
                                               "text.txt")),
                           '</p>')
                p = paste0("	    ", p, collapse="\n")
                folder = gsub(".*[$]P[$]", p, folder)
            }
            
            img = paste0('<div class="container_img"><img src="/',
                         folder_resource_dir, "/",
                         img, '"></div>')
            img = paste0("		", img, collapse="\n")
            folder = gsub(".*[$]IMG[$]", img, folder)

            writeLines(folder, folder_path)
        }

        
        folders = folders_default
        folders_path = file.path(pages_dir,
                                 to_link(tab),
                                 paste0(to_link(subtab),
                                        ".html"))

        folders = gsub(".*[$]TABBARjs[$]",
                       paste0('	<script src="/resources/js/',
                              to_link(tab), '_tab.js"></script>'),
                       folders)

        folders = gsub(".*[$]TITLE[$]",
                       paste0('	    <h1 class="text_center">',
                              tab, '</h1>'),
                       folders)

        folders = gsub(".*[$]TABBAR[$]",
                       paste0('	    <div class="tab_bar" id="',
                              to_link(tab), '_tab"></div>'),
                       folders)

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

    folders = folders_default
    folders_path = file.path(pages_dir,
                             paste0(to_link(tab),
                                    ".html"))

    folders = gsub(".*[$]TABBARjs[$]",
                   paste0('	<script src="/resources/js/',
                          to_link(tab), '_tab.js"></script>'),
                   folders)

    folders = gsub(".*[$]TITLE[$]",
                   paste0('	    <h1 class="text_center">',
                          tab, '</h1>'),
                   folders)
    
    folders = gsub(".*[$]TABBAR[$]",
                   paste0('	    <div class="tab_bar" id="',
                          to_link(tab), '_tab"></div>'),
                   folders)

    
    if (tab == "Projets") {
        Folder =
            paste0(paste0('		<a class="projet_thumbnail" href="/', Folders_path, '">
		    <div class="overlay"><h2>', Folders_type, '</h2><h3>', Folders_title, '</h3><h4>', Folders_subtitle, '</h4></div>
		    <img src="/', Folders_img, '">
		</a>'), collapse="\n\n")
        folders = gsub(".*[$]PROJET[$]", Folder, folders)
    }
    

    

    writeLines(folders, folders_path)
    
}


















