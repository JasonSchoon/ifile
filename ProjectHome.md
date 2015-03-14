# Project Overview #
This is a way to allow for internal file links to work from a website.  Specifically, there was a need to allow internal file links to network locations to work from an internal wiki.

After allowing the file type of "ifile" in the wiki software, this application takes care of the rest.

It is very simple for now.  It is out here to help educate, and to allow it to be improved/extended by others.

## What are these ifile: links? ##
ifile: is a custom URI protocol to work around web browsers not easily allowing internal file links to be clicked.  This enables the wiki to directly link to files anywhere on the internal network.

### Why do I need to use ifile:// rather than file://? ###
Most web browsers by default do not allow file:// links to access content when the page containing the link was accessed via http:// rather than file:// (as will always be the case on this wiki).  This is a security precaution to prevent content in the "Internet" zone to manipulate local content on the computer.

Rather than provide browser-specific workarounds, and potentially open a security hole, the use of a custom URI was chosen instead.  In this manner, all browsers are supported after the helper application is installed, and the helper application can provide validation and insure security is maintained.

### What is IFileHandler? ###
IFileHandler is a Windows installer.  It provides a handler for the ifile: URI protocol.

A small helper application named ifile.exe will be added to the Windows directory.

This installer will add necessary values to the registry to support the ifile: protocol in all web browsers.  It may still be necessary in some browsers to specify one time that the iFile Helper should be used to open ifile: links.

## Example usage ##
A wiki-formatted link to an internal folder would look as follows:
> ifile://some\_server/folder Link to Folder
> [ifile://some\_server/folder Link to Folder]

A simple inline link without wiki formatting could be:
> ifile://some\_server/folder

''Note: Directions of slashes are not important.  The helper application will automatically convert them to Windows-style backslashes.  If leading slashes are not included, they will be added.''

## Known issues ##
