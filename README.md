# GdriveArchive
WIP: I have a very messy and full google drive. I want to clean it up and archive all the things that are nice to have but I don't access often.

AIM: To run some sort of pipelines that allows someone to see all the files they have in gdrive and decide what to do with them:
- keep -> maintain a file where it is
- delete -> no longer needed, trash
- archive -> archive in s3 cold storage or equivalent. Ideally it would also remap it to a new location in the archive.

## Progress
- **04/02**: Define project, implement gdrive API file retrieval
- **29/03**: Add database, migrations and schemas, add file normalization
- **30/03**: Add Indexer module, fix small issues, run indexing job
- **02/04**: Implement tree builder and aggregate sizes at every tree level.

## TODOs
- Implement a way to reconstruct file trees from db (recursive CTEs?)
- Implement a way to identify duplicates and a UI to go through them and select which of them to keep (if any)
- Design a simple keyboard-based navigation UI (LiveView, TUI?) where information is well presented and actions are decided:
  - a(rchive): These will be marked for migration to a different storage location i.e S3 cold storage)
  - d(elete): These will be marked for deletion
  - k(eep): These will stay in gdrive
- Implement the above, it will probably need new db schemas to store that information
- Implement the jobs to execute the actions from the view

## Thoughts
- The hard part is triaging/pruning through all the files. The right level of granularity might be different. Some directories like `photography/raw` are just structured directories of raw files so they can be managed in bulk. Other directories are big mixes of all sorts of files (think of your `Downloads` folder).
Need to figure out a good tool to go through these.

I'm thinking that a TUI could be good enough for this, but a LiveView might actually be simpler to implement?

My idea would be that you're presented with a directory list, like the highest level, and then you can navigate through it with your keyboard, a bit like in lazygit. Then you can mark a file for deletion, archive or keep. When archiving you're presented the option of what's the path you want to archive this file to.

gdrive provides with an md5Checksum which should be used to prevent duplicates from being kept/archived.

- I guess the first step is to catalog every single file in the gdrive. Need to figure out a good way to encode those directory trees.
  - gdrive tells you the parent of a file, but we have multiple levels of nesting so a relational db might not be the best way to encode this. If you simply store all the data to a sqlite, what sort of query would you need to run to establish all the levels of nesting? Perhaps I can do some research on this, I'm sure there's known ways to encode it without going too over board.

- After that process, some sort of db persists the actions to be performed and then a job can be run to perform them.

- It took me a bit to realise how simple the implementation is for going from a flat node list to a tree. I guess TDD would've been the best approach for such a function, perhaps I could continue adding tests and using TDD in my next steps.

- Next step I think will be the LiveView, which means I need to add Phoenix to this already existing project... Perhaps I should build it as an umbrella? Otherwise I can go the TUI way, but I want to improve my LV skills so LiveView it is.