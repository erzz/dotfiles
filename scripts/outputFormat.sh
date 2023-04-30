##################### UTIL FUNCTIONS ######################
bold=$(tput bold)
green=$(tput setaf 2)
normal=$(tput sgr0)

title() {
  echo "${bold}==> $1${normal}"
}

indent() {
  sed 's/^/  /'
}