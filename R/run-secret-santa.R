#' Run entire secret santa process
#'
#' @description Caution!  This function will send e-mails with
#'              secret santa assignments!  This function executes the entire
#'              process from making assignments to sending e-mails to
#'              participants informing them of their match.  It also writes
#'              a log file of givers and recipients.
#' 
#' @param config_path file path to the \code{secretsanta} config JSON.
#'
#' @export
run_secret_santa <- function(config_path) {
  config     <- jsonlite::fromJSON(config_path)
  santa_data <- make_santa_data(config)

  send_all_emails(config, santa_data)
  write_assignments(config, santa_data)
}


send_all_emails <- function(config, santa_data) {
  for(i in 1:nrow(santa_data)) {
    this_mime <- build_mime(config, santa_data[i, , drop = FALSE])
    gmailr::gm_send_message(this_mime)

    print(paste("Sent email to", santa_data$giver[i],
                "at", santa_data$giver_email[i]))
  }
}


write_assignments <- function(config, santa_data) {
  write.csv(santa_data[c("giver", "recipient")],
            file = config$files$assignment_log,
            row.names = FALSE)
}