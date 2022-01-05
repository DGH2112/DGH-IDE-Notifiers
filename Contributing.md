# Contributing to DGH IDE Notifiers

Please try and follows the things that are layed out below as it will make it easier to accept a pull request however not following the below does not necessarily exclude a pull request from being accepted.

## Git Flow

For DGH IDE Notifiers I use Git as the version control but I also use [Git Flow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow) for the development cycles. The main development is undertaken in the **Development** branch with stable releases being in the **master**. All pull requests should be made from the **Development** branch, prefereably using **Feature** branches or **BugFix** branches. I've defined prefixes for these already in the `.gitconfig` file. You should submit onyl one change per pull request at a time to make it easiler to review and accept the pull request.

Tools wise, I generally use [Fork](https://fork.dev/) but that does not support Git Flow's **BugFix** functionality so I drop down to the command prompt to create **BugFix** branches as SourceTree can _Finish_ any type of open branch in Git Flow.

## Creating Pull Requests

Having not done this before as I've always been the sole contributor to my repositories so I borrowed the essense of the following from the [DUnitX](https://github.com/VSoftTechnologies/DUnitX) project:

1. Create a [GitHub Account](https://github.com/join);
2. Fork the DGH IDE Notifiers
   Repository and setup your local repository as follows:
     * Fork the [repository](https://help.github.com/articles/fork-a-repo);
     * Clone your Fork to your local machine;
     * Configure upstream remote to the **Development**
       DGH IDE Notifiers
       [repository](https://github.com/DGH2112/Integrated-Testing-Helper);
3. For each change you want to make:
     * Create a new **Feature** or **BugFix** branch for your change;
     * Make your change in your new branch;
     * **Verify code compiles for ALL supported RAD Studio version (see below) and unit tests still pass**;
     * Commit change to your local repository;
     * Push change to your remote repository;
     * Submit a [Pull Request](https://help.github.com/articles/using-pull-requests);
     * Note: local and remote branches can be deleted after pull request has been accepted.

**Note:** Getting changes from others requires [Syncing your Local repository](https://help.github.com/articles/syncing-a-fork) with the **Development** DGH IDE Notifiers repository. This can happen at any time.

## Dependencies

DGH IDE Notifiers has no dependencies at this time.

## Project Configuration

The DGH IDE Notifiers Open Tools API project uses a single projects file (`.DPR`) to compile to mutliple versions of RAD Studio by use 2 include files: one for compiler specific coding and the second to implement the correct suffix for the DLL.

The current code base only supports RAD Studio XE3 and above.

Note: The web page is out of date with regards to the supported versions above.

## Rationale

The following is a brief description of the rationale behind DGH IDE Notifiers. I will hopefully write more later.

The plug-in in itself does not do anything except hooks all the IDEs notifiers to demonstrate how this can be done. For a list of those currently implemented please refer tot he Readme.md file.

regards

David Hoyle Jan 2022
