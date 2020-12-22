# secretsanta
he's making a list, sampling it twice


## Ho ho ho!

This package will help you set up your annual Secret Santa event!
It creates giver/recipient pairs and sends e-mails to the givers to notify them
of their recipient name.  It then writes a file to record the pairs for
future reference.  The assignments aren't known unless someone opens the file,
which means that the organizer can also participate without knowing who
their Secret Santa is!


## Install
`devtools::install_github("ataustin/secretsanta")`


## Getting set up
Important!  This package uses the Gmail API which is accessed using the `gmailr` package. You must go through the setup, which is well documented in the `gmailr` github repo, available [here](https://github.com/r-lib/gmailr).


## Quick start

The workflow of this package looks like this:

```
library(secretsanta)

config_path <- "path/to/config.json"
authenticate(config_path)
run_secret_santa(config_path)
```

Read on to learn how to set up your credentials and the config.


## Setup details
To run a Secret Santa with this package, you will:

1. create a config file containing details about your setup;
2. authenticate with the Gmail API; and
3. kick off the e-mails.


### Step 1: Creating a config file
This package requires a config file in JSON format to store details about
your participants, files, and e-mails.  Here is a template:

```
{
  "participants": {
    "Dwight Schrute": "numberonesalesman@dundermifflin.com",
    "Jim Halpert": "jim@dundermifflin.com",
    "Pam Beesly": "pam@dundermifflin.com",
    "Angela Martin": "angela@dundermifflin.com"
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
      "replacements": {
        "giver": "GIVER",
        "recipient": "RECIPIENT"
      }
    }
  }
}
```

#### `participants`
These are key-value pairs, with participant names as the keys and their
e-mail addresses as the values.  These are used for making assignments
and sending e-mails.  Names will be used in the `GIVER` and `RECIPIENT` fields
of the e-mails.

#### `files`
These are the file paths used by the package.  the `gmailr_credentials` file
is what you saved in the process of getting `gmailr` set up.  The
`assignment_log` is the path where the package will write the CSV log of givers
and recipients in case it is needed.

#### `email_settings`

##### `author`
This is the person from whom the Secret Santa assignment e-mails will appear
to come.  This is usually the organizer, as participants may need to reply to
the e-mail with questions.

##### `message`
`subject` will be the e-mail subject line.

`body` will be the body of the message.  This is best kept short and simple.
The `GIVER` and `RECIPIENT` fields will be swapped out by participant names
automatically when the package does its work.  You can change the message
and the field names, but be sure that the giver field keyword and the
recipient field keyword match exactly what is in the `replacements` section
of the JSON.  Participant names are substituted into these positions using
regular expression matching.


### Step 2: Authenticate
For convenience, the package wraps the Gmail API authentication steps.
After following the `gmailr` setup, simply do the following:

```
authenticate("path/to/config.json")
```


### Step 3: Send e-mails

#### Optional: send test e-mail
You may wish to test your setup prior to sending Secret Santa e-mails to all participants:

```
test_secret_santa("path/to/config.json", mail_to = "your_address@domain.com")
```

This function performs all giver/recipient assignments and then sends one
test message, as it would appear to someone in your pool, to the e-mail
address you specify.  This allows you to ensure the e-mail looks the way
you intend.

#### Run the Secret Santa process
When you are ready to randomize the giver/recipient pairs and send e-mails to
all participants, simply do the following:

```
run_secret_santa("path/to/config.json")
```

This executes the entire process and writes a log file of assignments.
Happy giving!


## A note on randomization

The package makes giver/recipient pairs by scrambling the names of participants
using `sample` and assigning each person to the one after them in the vector
(the last person in the vector is assigned the first person).  This creates
a single closed loop of givers and recipients so that, during gift opening,
the flow can continuously move from recipient to giver until all participants
have opened their gifts.