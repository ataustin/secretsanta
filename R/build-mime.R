build_mime <- function(config, santa_row) {
  mime    <- gmailr::gm_mime()
  to      <- gmailr::gm_to(mime, santa_row$giver_email)
  from    <- gmailr::gm_from(to, build_author(config))
  subject <- gmailr::gm_subject(from, config$email_settings$message$subject)
  out     <- gmailr::gm_text_body(subject, santa_row$body)

  out
}


build_author <- function(config) {
  paste0(config$email_settings$author$name,
         " <", config$email_settings$author$email_address, ">")
}