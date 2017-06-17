################################################################################
# Fonts                                                                        #
################################################################################
info "Installing extra fonts, install them with Font Book when it fires up."

mkdir fonts
cp /Applications/Xcode.app/Contents/SharedFrameworks/DVTKit.framework/Versions/A/Resources/Fonts/SFMono-* fonts
open fonts/*.otf

ask "Finished installing fonts with Font Book?"
rm -rf fonts
