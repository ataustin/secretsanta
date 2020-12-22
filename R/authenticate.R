#' Authenticate with the gmail API.
#'
#' @description Simple convenience function to authenticate with gmail
#'              prior to sending e-mails.  This can be skipped if the user
#'              chooses to authenticate separately.
#' 
#' @param config_path file path to the \code{secretsanta} config JSON.
#'
#' @export
authenticate <- function(config_path) {
  config <- jsonlite::fromJSON(config_path)
  gmailr::gm_auth_configure(path = config$files$gmailr_credentials)
  gmailr::gm_auth()
}
