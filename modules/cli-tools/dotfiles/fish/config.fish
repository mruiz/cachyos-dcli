if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Set cursor theme for niri compositor
set -gx XCURSOR_THEME Bibata-Modern-Ice
set -gx XCURSOR_SIZE 24

# Add scripts directory to PATH
fish_add_path $HOME/.config/scripts
# Use the global FVM-managed Flutter SDK for direct `flutter`/`dart` commands.
fish_add_path $HOME/fvm/default/bin
# Pour utiliser Neovim par exemple
export EDITOR="helix"
starship init fish | source

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /home/mathieu/.lmstudio/bin
# End of LM Studio CLI section

# Hermes Agent command
fish_add_path "$HOME/.local/bin"
