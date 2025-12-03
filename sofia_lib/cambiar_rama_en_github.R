# 1. Listar todas las ramas (locales y remotas)
system("git branch -a")

# 2. Crear la rama local 'monthlydata' a partir de la remota y cambiarte a ella
system("git checkout -b monthlydata origin/monthlydata")

# 3. Verificar en qué rama estás ahora
system("git branch")

# 4. Traer los últimos cambios de la rama remota (opcional pero recomendable)
system("git pull")
