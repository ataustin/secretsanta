# secretsanta

He's making a list, sampling it twice :santa:



## Ho ho ho!

This package will help you set up your annual Secret Santa event!

You supply a list of participant names, and `secretsanta` will randomize them
into giver/recipient pairs. The package then e-mails each person to tell them
who their unsuspecting recipient is.

The full list of giver/recipient assignments is kept secret, even from the person who uses
this package. That means the event organizer can also participate in the gift-giving
without spoiling any surprises. However, the package also logs the assignments
in a CSV for future reference, in case it is needed (but no peeking!).



## Install

`remotes::install_github("ataustin/secretsanta")`



## Overview

The workflow of this package looks like this:

```
library(secretsanta)

santa_config <- "path/to/config.json"   # specifies information for your event
authenticate(santa_config)              # allows R to communicate with Gmail via API
run_secret_santa(santa_config)          # randomizes participants and sends e-mails
```

To use this package, first set up your Gmail credentials, then create a config. Read on
for details!



## Authentication with Gmail

This package uses the Gmail API which is accessed using the `gmailr` package
documented [here](https://github.com/r-lib/gmailr#gmailr).
Setting up your authentication will be the hardest part of using this package. Please
follow the "Setup and auth" section of the `gmailr` docs to learn more.

Your goal during setup is the following:

* create a project on Google Cloud Platform
* generate OAuth Client ID credentials for desktop
* download the OAuth client JSON

This client JSON file will become the credential file used in the `secretsanta` config.



## Write a `secretsanta` config file

This package requires a config file in JSON format to store details about
your participants, file locations, and the e-mail to send.  Here is a template:

```
{
  "participants": {
    "contact": {
      "Jim": "jim@dundermifflin.com",
      "Pam": "pam@dundermifflin.com",
      "Angela": "angela@dundermifflin.com",
      "Dwight": "assistantregionalmanager@dundermifflin.com",
      "Michael": "number1boss@dundermifflin.com"
    },
    "do_not_pair": {
      "Dwight": "Jim",
      "Jim": "Pam"
    }
  },
  "files": {
    "gmailr_credentials": "/path/to/gmail-api/credentials.json",
    "assignment_log": "/path/to/write/assignments.csv"
  },
  "email_settings": {
    "author": {
      "name": "Jim Halpert",
      "email_address": "jim@dundermifflin.com"
    },
    "message": {
      "subject": "Dunder Mifflin Secret Santa",
      "body": "Dear GIVER,\nHo ho ho!  Your Secret Santa recipient is RECIPIENT.\nYours,\nSanta"
    }
  }
}
```

Here are some details about the fields:

* **participants**
  * **contact**: key-value pairs of participant names and e-mails addresses. Keys must be
                 unique, so if you have two Bobs, include last names in the key, e.g. "Bob Jones" and "Bob Smith"
  * **do_not_pair**: _optional section_; if you wish to prevent two people from being matched
                     (for example spouses or pranksters), list their names here as key-value pairs.
                     The names must match a key in the **contact** section. This is a two-way
                     exclusion, so a single key-value pair will prevent both parties from being matched to the other.
* **files**
  * **gmailr_credentials**: file path pointing to the JSON credentials file for the Gmail API
  * **assignment_log**: file path where you want to write the CSV log file of givers and recipients
* **email_settings**
  * **author**
    * **name**: the Secret Santa e-mail will appear to come from this person
    * **email_address**: the Secret Santa e-mail will appear to come from this address
  * **message**
    * **subject**: the subject line for the Secret Santa e-mail
    * **body**: the body of the Secret Santa e-mail, best kept short and sweet. _Important_: you must include the terms
                `GIVER` and `RECIPIENT` (in capital letters) in this field. These words will be
                replaced with actual giver & recipient names before the e-mail is sent.



## Authenticate

Once you set up Gmail authentication and have written your config, you can authenticate:

```
authenticate("path/to/config.json")
```

This connects you to Gmail and allows you to send e-mails.  Even if you used this package in the past,
you may have to jump through authorization hoops using your browser to give permissions to
`secretsanta` again.  See the "Final notes" section below for more information.



## Test before going live

After authentication, you may wish to test your config prior to sending
Secret Santa e-mails to all participants:

```
test_secret_santa("path/to/config.json", mail_to = "your_address@domain.com")
```

This function performs random giver/recipient assignments and then sends one
test message, as it would appear to someone in your participant pool, to the e-mail
address you specify.  This allows you to ensure that the e-mail looks the way
you intend.

Testing does not spoil any surprises, because giver/recipient pairs are
always re-randomized anytime e-mails are sent.

Please note testing does NOT save a CSV log file.



## Send the Christmas joy!

When you are ready to randomize the giver/recipient pairs and send e-mails to
all participants, run the following:

```
run_secret_santa("path/to/config.json")
```



## Final notes

### How randomization works

The package makes giver/recipient pairs by scrambling the names of participants
using `sample()` and assigning each person to the one after them in the resulting vector
(with recycling).  This creates a single closed loop of givers and recipients so that,
during gift opening, the flow can continuously move from recipient to giver until all participants
have opened their gifts.


### Authentication is designed to frighten you

The first time you run `authenticate()` Google will provide you with an alarming
number of scary-looking screens and e-mails.  You will have to proceed past an "unsafe"
screen and give `secretsanta` read & write access to your Gmail account.

Rest assured that only your local copy of `secretsanta` gets these privileges, not
the package author or anyone else.  It's the same process as connecting any app to your e-mail client.
If you aren't sure, feel free to browse the source code of the repo to see what the
package is doing.  Interaction with Gmail occurs through the `gmailr` package only
and the package is only sending new e-mails, not looking for or modifying existing ones.


### Troubleshooting authentication

Authentication with the Gmail API can be a headache.  If it's not working, try the following:

* install the dev version of `gargle` with `remotes::install_github("r-lib/gargle")` to get the latest patches
* use R for desktop (rather than, say, RStudio Server even if running locally)
* ensure your OAuth client's credential type is "desktop"


### Authentication & RStudio Server

As of the 2022 season, I wasn't able to authenticate using RStudio Server
running in WSL2. This is probably due to Google's
[deprecation of out-of-band workflows](https://developers.google.com/identity/protocols/oauth2/resources/oob-migration).
While I haven't had time to debug this, I was able to authenticate from RStudio
running on the desktop using an OAuth client ID for desktop app.
