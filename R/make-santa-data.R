#' Make secret santa data
#'
#' @description This function turns the config data into secret santa
#'              assignments and composes the customized e-mail message.
#'              This function is called from \code{run_secret_santa} but is
#'              exported in case the user wishes to study how the package
#'              makes assignments and build messages.
#' 
#' @param config the parsed \code{secretsanta} config obtained by passing the
#'               config JSON file through \code{jsonlite::fromJSON}.
#'
#' @export
make_santa_data <- function(config) {
  givers    <- sample(config$participants)
  recipients <- c(tail(givers, length(givers) - 1), givers[1])

  santa_data <- data.frame(giver = names(givers),
                           recipient = names(recipients),
                           giver_email = unname(unlist(givers)))

  santa_data$body <- build_email_message(config, santa_data)
  santa_data
}


build_email_message <- function(config, santa_data) {
  message <- rep(config$email_settings$message$body, nrow(santa_data))

  for(i in seq_along(message)) {
    message[i] <- gsub(config$email_settings$message$replacements$giver,
                       santa_data$giver[i],
                       message[i])
    message[i] <- gsub(config$email_settings$message$replacements$recipient,
                       santa_data$recipient[i],
                       message[i])
  }

  message
}
