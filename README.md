# satellite-documentation-tools

This is the beginning of a set of tool will assist in documenting the configuration of Satellite that is formatted either as MarkDown or AsciiDoc of the contents of the Satellite 6 Server.   This information can be used to create or add to documentation or journals.  It can be used to archive configuration changes in the satellite over time.

`satellite-configuration-dump.sh`will dump out the internal objects of Satellite in a MarkDown or AsciiDoc format.  These format will allow the user to keep the document in it entire form or select segments of it to be incorporated into other documentation.

It can be used as a diagnostic tool to check hidden values in the configuration or setup of the Satellite 6 Server. It can be run via cron to a dated file to track changes over time.  Use `diff` to see those changes.  Sometimes there are settings in Satellite 6 that are not apparent in the Web GUI that can be seen in this dump of the configuration.

Download the program and make it executable.

```bash
$ chmod 700 satellite-configuration-dump.sh
```
## Requirements

Hammer must be installed on the server or client running the script.

## Options:

* `-l`, `--listing filename.<adoc|md>` Type of listing either MarkDown or Asciidoc.
* `-o`, `--organization organization_name` Name of the Satellite organization to dump it configuration.
* `-t`, `--type <AD|MD>` Type of Report: `AD` (asciidoc) or `MD` (markdown).
* `-h`, `--help` Usage information.

## Examples

To get help on how to use it on the command-line.

```bash
./satellite-configuration-dump.sh -h
```
or

```bash
 ./satellite-configuration-dump.sh --help
```

To generate a AsciiDoc report of the configuration -- long option form

```bash
./satellite-configuration-dump.sh --organization ACME --listing ACME.adoc --type AD
```

To make a periodic dump of Satellite 6 Settings, add this to `/etc/cron.d`:

```bash
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
SCRIPT=/root/bin/satellite-documentation-tools/satellite-configuration-dump.sh
NOW=$(date +"%Y-%m=%d-%k:%M:%S")
DESTDIR=/var/tmp

# Clean up the session entries in the database
* 0 * * *     root	$SCRIPT --organization ACME --type AD --listing $DESTDIR/ACME-${NOW}.md
```

## License

![](https://www.gnu.org/graphics/gplv3-with-text-136x68.png)GPL 3.0 or later.   https://www.gnu.org/licenses/gpl-3.0.en.html

## History and REVISIONS

| Version | Date       | Authors      | Changes                                |
| :------ | :--------- | :----------- | -------------------------------------- |
| 1.0.0   | 2019-02-14 | Scott Parker | Script Creation - In it's current Form |




