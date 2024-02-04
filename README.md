# GdriveArchive
WIP: I have a very messy and full google drive. I want to clean it up and archive all the things that are nice to have but I don't access often.

AIM: To run some sort of pipelines that allows someone to see all the files they have in gdrive and decide what to do with them:
- keep -> maintain a file where it is
- delete -> no longer needed, trash
- archive -> archive in s3 cold storage or equivalent. Ideally it would also remap it to a new location in the archive.

## Thoughts
- The hard part is triaging/pruning through all the files. The right level of granularity might be different. Some directories like `photography/raw` are just structured directories of raw files so they can be managed in bulk. Other directories are big mixes of all sorts of files (think of your `Downloads` folder).
Need to figure out a good tool to go through these.

I'm thinking that a TUI could be good enough for this, but a LiveView might actually be simpler to implement?

My idea would be that you're presented with a directory list, like the highest level, and then you can navigate through it with your keyboard, a bit like in lazygit. Then you can mark a file for deletion, archive or keep. When archiving you're presented the option of what's the path you want to archive this file to.

gdrive provides with an md5Checksum which should be used to prevent duplicates from being kept/archived.

- I guess the first step is to catalog every single file in the gdrive. Need to figure out a good way to encode those directory trees.
  - gdrive tells you the parent of a file, but we have multiple levels of nesting so a relational db might not be the best way to encode this. If you simply store all the data to a sqlite, what sort of query would you need to run to establish all the levels of nesting? Perhaps I can do some research on this, I'm sure there's known ways to encode it without going too over board.

- After that process, some sort of db persists the actions to be performed and then a job can be run to perform them.


Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/gdrive_archive>.

