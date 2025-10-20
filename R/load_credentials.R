#' @title Load credentials from environment variables
#' @description Reads credentials stored in environment variables
#' and saves them as an internal variable so they are available
#' automatically when the get_monthtly_single.R and get_annual_single.R scripts are
#' loaded.
#' @keywords internal

# load_credentials <- function() {
#
#   access_key <- Sys.getenv("ACCESS_KEY_ID")
#   secret_key <- Sys.getenv("SECRET_ACCESS_KEY")
#
#   if (access_key == "" || secret_key == "") {
#     warning("⚠️ No S3 credentials found. Please set MY_API_KEY1 and MY_API_KEY2.")
#     return(NULL)
#   }
#
#   # Crear objeto global interno con las credenciales
#   assign(
#     "credentials",
#     list(
#       access_key_id = access_key,
#       secret_access_key = secret_key
#     ),
#     envir = parent.env(environment()) # lo guarda en el entorno del paquete
#   )
#
#   invisible(TRUE)
# }
#
#


access_key <- Sys.getenv("ACCESS_KEY_ID", unset = "")
secret_key <- Sys.getenv("SECRET_ACCESS_KEY", unset = "")

if (access_key == "" || secret_key == "") {
  stop("⚠️ Missing S3 credentials (MY_API_KEY1 or MY_API_KEY2). Set them as environment variables.")
}

s3_credentials <- list(
  access_key_id = access_key,
  secret_access_key = secret_key
)

# mensajito opcional (evita imprimir valores)
packageStartupMessage("✅ S3 credentials loaded into 's3_credentials' (not printed).")




