# Scripts

## Default IRI setup

One-line linux command to set up IOTA node with nelson peer discovery:
`sudo curl https://raw.githubusercontent.com/tanglewise/Scripts/master/IRI_node_setup.sh | bash`

One-line linux command to upgrade to IRI (same 1.4.2.4 version):
`sudo curl https://raw.githubusercontent.com/tanglewise/Scripts/master/IRI_upgrade.sh | bash`


## Modified IRI setup

One-line linux command to set up IOTA node with Nelson and ITI spamming capabilities:
`sudo curl https://raw.githubusercontent.com/tanglewise/Scripts/master/ITI_node_setup.sh | bash`

One-line linux command to upgrade modified ITI (same 1.4.2.4 version):
`sudo curl https://raw.githubusercontent.com/tanglewise/Scripts/master/ITI_upgrade.sh | bash`

## New IRI setup

One-line linux command to set up IOTA node with Nelson and ITI spamming capabilities:
`sudo curl https://raw.githubusercontent.com/tanglewise/Scripts/master/NewIRI_upgrade.sh | bash`

## Spammer setup

One-line linux command to install Java spammer with Go POW:
`sudo curl https://raw.githubusercontent.com/tanglewise/JavaGoSpam/master/go_spam_setup.sh | bash`
Then to run: `cd /home/iota/spam/JavaGoSpam && java -jar twspam-1.jar`

[How to set up IOTA node on Google Compute Engine for free](https://github.com/tanglewise/Tutorials/blob/master/google_compute_node_setup.md)
