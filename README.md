# dot
A simple but terrible util for dotfile git management / github publishing

## Install
drop `dot.sh` at somewhere you like, and then add `alias dot=...` in .bashrc to allow easy access of command  

## Basic features
```bash
dot -u	# show usage and exit (u = usage)
dot -w	# show tracked files (w = what)
dot -r	# reset all and discard original git (r = reset)
dot -b *path* # set base directory of all dotfiles to be tracked (b = base)
dot -i  # init dotfiles git (i = init)
dot -o *origin* # git remote set origin (o = origin)
dot -f  # git pull (f = fetch)
dot -p  # git push origin master (p = push)
dot -s [filenames] # record and overwrite all files that need to be tracked in .dotrc (s = save)
dot -m *filename* # add a single file to all the dotfiles that need to be tracked (m = more)
dot -l *filename* # remove some file from .dotrc tracking (l = less)
dot -a  # stage all files specified in .dotrc (a = add)
dot -c "Message" # commit with commit message (c = commit)
```

## Example
```bash
$ dot -b ~
# setting base path for .git, which will be created and placed in dot -i step below
$ dot -i
# empty .git inited
$ dot -s file0 file1 file2 file3
# file0 file1 file2 file3 tracked
$ dot -o http://github.com/someone/somerepo.git
# origin added
$ dot -m file4
# file4 tracking added
$ dot -l file0
# file0 no longer update tracking
$ dot -a
# staging file1, file2, file3 and file4
$ dot -c "Initial Commit"
# commit success of staged files
$ dot -p
# pushed to github
```

## Sorry
This project will be absolutely lame. There is no support for branches: everything is commited and pushed to __master__ branch. It is created mostly just for fun and for personal use, so many advanced features will NOT be implemented (at least for now as I am a terrible programmer at this stage...)  
No matter what, this repo itself is tracked and updated with `dot`, which actually serves as just a util to simply remember which files in the same folder is partially tracked
