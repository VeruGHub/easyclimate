api_key <- Sys.getenv("secrets.ACCESS_KEY_ID")
password <- Sys.getenv("secrets.SECRET_ACCESS_KEY")

# Ejemplo de uso:
cat("La clave API tiene longitud:", nchar(api_key), "\n")

