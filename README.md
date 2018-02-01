# mailbox2vcf

Creates addressbook export file in vcf format from a mailbox

## requirements

* ruby
* gem

## installation

    gem install maildir
    gem install mail

## running

    ruby mailbox2vcf [my_mailbox_directory] [outputfile] [maildir_subdirs]

The my_mailbox_directory have to contain a cur folder with messages.

After that we can import the output.txt file for example to the owncloud address book.

# example

    ruby mailbox2vcf john@doe.com export.vcf cur
