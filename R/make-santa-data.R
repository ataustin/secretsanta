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
  santa_data <- build_pairs(config)

  if(!is.null(config$participants$do_not_pair)) {
    validate_no_pair_names(config)
    while(violates_pair_restriction(config, santa_data)) {
      santa_data <- build_pairs(config)
    }
  }
  
  santa_data$body <- build_email_message(config, santa_data)
  santa_data
}


build_pairs <- function(config) {
  givers     <- sample(config$participants$contact)
  recipients <- c(tail(givers, length(givers) - 1), givers[1])
  
  pair_data <- data.frame(giver = names(givers),
                          recipient = names(recipients),
                          giver_email = unname(unlist(givers)))
  
  pair_data
}


validate_no_pair_names <- function(config) {
  no_pair_list  <- config$participants$do_not_pair
  no_pair_names <- c(names(no_pair_list), unname(unlist(no_pair_list)))
  participants  <- names(config$participants$contact)
  
  invalid_names <- setdiff(no_pair_names, participants)
  if(length(invalid_names)) {
    err <- paste0("Found names in 'do_not_pair' that do not match names ",
                  "in 'contact':\n",
                  paste(invalid_names, collapse = ", "))
    stop(err, call. = FALSE)
  }
  
  duplicated_names <- participants[duplicated(participants)]
  if(length(duplicated_names)) {
    err <- paste0("To use 'do_not_pair' please ensure participant names ",
                  " are unique. The following names are duplicated:\n",
                  paste(unique(duplicated_names), collapse = ", "))
    stop(err, call. = FALSE)
  }
}


violates_pair_restriction <- function(config, santa_data) {
  no_pair   <- setNames(stack(config$participants$do_not_pair),
                        c("giver", "do_not_pair"))
  no_pair[] <- lapply(no_pair, as.character)
  no_pair   <- rbind(no_pair, setNames(no_pair, c("do_not_pair", "giver")))
  pair_test <- merge(santa_data, no_pair, by = "giver")
  violation <- any(pair_test$recipient == pair_test$do_not_pair)
  violation
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
