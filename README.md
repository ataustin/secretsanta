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


## Quick start

The workflow of this package looks like this:

```
library(secretsanta)

config_path <- "path/to/config.json"
authenticate(config_path)
run_secret_santa(config_path)
```

Before you begin, please read on to learn how to set up your credentials
and the config.


## Getting set up
Important!  This package uses the Gmail API which is accessed using the `gmailr` package, documented [here](https://github.com/r-lib/gmailr).
Unfortunately, using the Gmail API has become more difficult.  You must set up a project on Google Cloud Platform (console.cloud.google.com).
Within this project, from the API menu, you must create an OAuth Client ID and download the client JSON.  This will be your credential file
for use in the `secretsanta` package.


## Workflow details
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
    "contact": {
      "Dwight": "numberonesalesman@dundermifflin.com",
      "Jim": "jim@dundermifflin.com",
      "Pam": "pam@dundermifflin.com",
      "Angela": "angela@dundermifflin.com"
    },
    "do_not_pair": {
      "Dwight": "Jim"
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
      "replacements": {
        "giver": "GIVER",
        "recipient": "RECIPIENT"
      }
    }
  }
}
```

#### `participants`

##### `contact`
These are key-value pairs, with participant names as the keys and their
e-mail addresses as the values.  These are used for making assignments
and sending e-mails.  Names will be used in the `GIVER` and `RECIPIENT` fields
of the e-mails.

##### `do_not_pair`
This section is optional. If there are pairs of people who should not be matched
(_e.g._ spouses or pranksters) list them here as key-value pairs. This is a *two-way*
exclusion, so a single key-value pair will mean neither party will be matched to the other.
The names in `do_not_pair` must match keys in the `contact` section and all keys in the
`contact` section must be unique.


#### `files`
These are the file paths used by the package.  the `gmailr_credentials` file
is what you saved in the process of getting `gmailr` set up.  The
`assignment_log` is the path where the package will write the CSV log of givers
and recipients in case it is needed.


#### `email_settings`

##### `author`
This is the person from whom the Secret Santa e-mails will appear
to be sent.  This is usually the organizer, as participants may need to reply to
the e-mail with questions.

##### `message`
`subject` will be the e-mail subject line.

`body` will be the body of the message.  This is best kept short and sweet.
The `GIVER` and `RECIPIENT` fields will be swapped out by participant names
automatically when the package does its work.  You can change the message
and the field names, but be sure that the giver field keyword and the
recipient field keyword match exactly what is in the `replacements` section
of the JSON.  Participant names are substituted into these positions using
regular expression matching.


### Step 2: Authenticate
For convenience, the package wraps the Gmail API authentication steps.
After following the `gmailr` setup, simply call:

```
authenticate("path/to/config.json")
```

and follow any on-screen prompts from Google.


### Step 3: Send e-mails

#### Optional: send test e-mail
You may wish to test your setup prior to sending Secret Santa e-mails to all participants:

```
test_secret_santa("path/to/config.json", mail_to = "your_address@domain.com")
```

This function performs random giver/recipient assignments and then sends one
test message, as it would appear to someone in your pool, to the e-mail
address you specify.  This allows you to ensure the e-mail looks the way
you intend.

Testing does not spoil any surprises, because giver/recipient pairs are
re-randomized when you perform the next, final step.


#### Run the Secret Santa process
When you are ready to randomize the giver/recipient pairs and send e-mails to
all participants, simply do the following:

```
run_secret_santa("path/to/config.json")
```

This executes the randomization and e-mail process and writes a log file of assignments.
Happy giving!


## A note on randomization

The package makes giver/recipient pairs by scrambling the names of participants
using `sample` and assigning each person to the one after them in the vector
(the last person in the vector is assigned the first person).  This creates
a single closed loop of givers and recipients so that, during gift opening,
the flow can continuously move from recipient to giver until all participants
have opened their gifts.
