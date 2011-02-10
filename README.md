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
