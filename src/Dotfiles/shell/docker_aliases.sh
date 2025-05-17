# Docker Related stuff #
# sudo curl -L
# "https://github.com/docker/compose/releases/download/1.28.2/docker-compose-$(uname
# -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# sudo chmod +x /usr/local/bin/docker-compose
# dc up -dV --build --remove-orphan --force-recreate
alias d='docker '
alias de='docker exec -it '
alias dc='docker compose '
alias dce='docker compose exec -u $(whoami) '
alias dcE='docker compose exec -u root '
alias ds='docker compose ps --services'
alias dcb='docker compose --verbose up -dV --build --remove-orphans --force-recreate '
alias dcu='docker compose --verbose up -dV --remove-orphans --force-recreate '
alias dcdV='docker compose down --volumes '
alias dcl='docker compose logs --follow --timestamps --tail 50 '
alias dIps="docker ps -q | xargs -n 1 docker inspect --format '{{ .NetworkSettings.IPAddress }} {{ .Name }} {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' | sed 's/ \// /'"
alias dm="docker-machine"