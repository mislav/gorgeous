# Filthy → gorgeous

Convert between formats.

Usage:

    gorgeous [-i] [-F <in-format>] [-T <out-format>] [-q <query>] [-o <destination>] FILE ...

This utility converts data between different formats.  
Formats are one of:  json, xml, yaml, ruby, email, url

Input can be read from STDIN as well as files given on the command-line.

Options:

    -i    Convert file in-place
    -F    Input format
    -T    Output format
    -q    Query selector in format similar to XPath (see below)
    -o    Write output to file instead of STDOUT

Query format:

    "/items/comments[1]/text"    --  2nd comment body of each item
    "/items[-1]/user/full_name"  --  name of user for last item
    "//user/username"            --  usernames of all users anywhere in the document

## Prerequisites

It's recommended that you install all of these ruby libraries. They are only loaded when processing specific formats.

* **nokogiri** for HTML/XML
* **yajl-ruby** or **json** for JSON (for Ruby < 1.9)
* **activesupport** (for various stuff)
* **rack** for url
* **mail** for email

All together now:

    $ gem install nokogiri yajl-ruby activesupport rack mail

## Examples

Pipe in standard input:

    # auto-detects input as being JSON, displays prettified output:
    $ curl -s api.twitter.com/1/statuses/show/40453487309361153.json | gorgeous
    
    # covert from JSON to YAML
    $ curl -s <url> | gorgeous -T yaml
    
    # extract Twitter avatar from tweet as text
    $ curl -s <url> | gorgeous -T txt -q /user/profile_image_url

Prettify a file in place:

    # auto-detects format by extension, prettifies and overwrites the file:
    $ gorgeous -i some-data.json
    
    # convert some data to YAML
    $ gorgeous -i -F json -T yaml some-data

Prettify some HTML (gorgeous calls it "xml"):

    $ curl -s www.1112.net/lastpage.html | gorgeous -F xml

Prettify content in clipboard (on a Mac):

    $ pbpaste | gorgeous | pbcopy

    # convert from YAML to ruby format and copy to clipboard
    $ gorgeous fixture.yml -T ruby | pbcopy

Parse query strings and URL-encoded POST payloads:

    $ echo 'sourceid=chrome&ie=UTF-8&q=filthy+gorgeous' | gorgeous -T yaml
    --- 
    sourceid: chrome
    q: filthy gorgeous
    ie: UTF-8

Parse emails:

    # extract prettified HTML part of the email:
    $ cat email.raw | gorgeous -F email -T xml

    # extract decoded text part of the email:
    $ cat email.raw | gorgeous -F email -T txt

    # get email headers as JSON:
    $ cat email.raw | gorgeous -F email -T json

    # get only the email subject:
    $ cat email.raw | gorgeous -F email -T txt -q /subject
