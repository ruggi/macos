function info() {
  printf "\e[33m★ $1\e[0m\n"
}

function success() {
  printf "\e[32m✓ $1\e[0m\n\n"
}

function fail() {
  printf "\n\e[31m✗ $1\e[0m\n"
  exit 1
}

function ask() {
  while true ; do
    read -p "🏗️  $1 " choice
    case "$choice" in
      y|Y) return 0 ;;
      n|N) return 1 ;;
      * );;
    esac
    echo 'Please answer with (Yy)es or (Nn)o.'
  done
}
