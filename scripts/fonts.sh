################################################################################
# Fonts                                                                        #
################################################################################
info "Installing extra fonts, install them with Font Book when it fires up."

open /Applications/Utilities/Terminal.app/Contents/Resources/Fonts/*.otf

ask "Finished installing fonts with Font Book?"
rm -rf fonts
