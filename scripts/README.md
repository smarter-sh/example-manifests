# Scripts

Some things can't be described by a manifest: a database that a SqlConnection connects to, data that must be seeded
through the platform's api once its resources exist, and so on. A repository of Smarter manifests keeps the scripts
that set them up in its top-level `scripts/` folder. This repository has none yet. The folder holds what you need
to add one:

| File                                       | What it is                                                               |
| ------------------------------------------ | ------------------------------------------------------------------------ |
| [`scripts.yaml`](scripts.yaml)             | The list of scripts that Smarter runs, and when. Empty, with an example  |
| [`getting-started.sh`](getting-started.sh) | A starting point to copy. It prints its environment, and changes nothing |
| `README.md`                                | This page                                                                |

`getting-started.sh` isn't listed in `scripts.yaml`, so Smarter never runs it.

## When scripts run

Every Smarter platform runs `manage.py initialize_platform` when it's deployed, and that runs
`manage.py load_from_github --run_scripts` on this repository. Then:

1. the `pre` scripts run, before any manifest is applied, so that what the manifests name exists when they're
   applied, e.g. a database;
2. every manifest is applied, and the LLMClients deployed;
3. the `post` scripts run, e.g. to seed data through the platform's api.

Within a stage, scripts run in the order of `scripts.yaml`.

**Only `initialize_platform` runs scripts.** Scripts run only when `load_from_github` is given `--run_scripts`,
and `initialize_platform` is the only command that gives it. `manage.py initialize_account`, which loads
repositories for each new account, doesn't, so a script runs once per platform deployment, not once per account.
Write each script so that running it again is safe: it runs at every deployment.

Smarter never looks for manifests in `scripts/`, so a YAML file here is never applied.

## `scripts.yaml`, field by field

```yaml
scripts:
  - path: create-example-database.sh # required
    stage: pre # required
    description: Create the database that the SqlConnection connects to.
    args: [--quiet] # optional
    timeout: 300 # optional
```

| Field         | Required | What it is                                                                                                  |
| ------------- | -------- | ----------------------------------------------------------------------------------------------------------- |
| `path`        | yes      | The script's file, relative to `scripts/`. It must stay inside `scripts/`: no absolute paths, no `..`       |
| `stage`       | yes      | `pre`: before any manifest is applied. `post`: after every manifest is applied, and the LLMClients deployed |
| `description` | no       | What the script does, for the people who read the file                                                      |
| `args`        | no       | The script's arguments, a list of strings. The default is none                                              |
| `timeout`     | no       | The seconds that the script may run, from 1 to 3600. The default is 300                                     |

No other field is allowed. `scripts: []`, as now, runs nothing. Only the scripts listed here run, so the folder may
also hold the files they read, e.g. a SQL file.

The whole file is checked before anything runs: if it isn't valid YAML, has an unknown field or a wrong value, or
names a script that isn't in `scripts/` or isn't executable, `load_from_github` fails at once, and applies nothing.

## How a script runs

- **As an executable**, with its own `#!` line, so commit it with its executable bit set: `chmod +x`, then
  `git add`. Git records the bit; GitHub's web editor can't set it.
- **In the repository's root folder**, a fresh, shallow clone of this repository's default branch, with the `args`
  of its entry.
- **With only these environment variables**:

  | Variable                          | Value                                                                                                       |
  | --------------------------------- | ----------------------------------------------------------------------------------------------------------- |
  | `SMARTER_REPOSITORY_URL`          | This repository's url                                                                                       |
  | `SMARTER_REPOSITORY_ROOT`         | The folder it was cloned into, which is also the script's working folder                                    |
  | `SMARTER_ACCOUNT_NUMBER`          | The account that owns the repository's resources                                                            |
  | `SMARTER_USERNAME`                | The user that owns them                                                                                     |
  | `SMARTER_DATABASE_HOST`           | The host of the platform's database server                                                                  |
  | `SMARTER_DATABASE_PORT`           | Its port                                                                                                    |
  | `SMARTER_DATABASE_ADMIN_USERNAME` | Its administrator                                                                                           |
  | `MYSQL_PWD`                       | The administrator's password, where the MariaDB and MySQL clients read it. Missing if the platform has none |

  plus `PATH`, `HOME`, `LANG`, `LC_ALL` and `TZ`, if the platform has them, and nothing else.

- **Its output is logged**, line by line, after the script's name: standard output as its report, standard error as
  warnings. Write one self-contained line per event, and never print a password.

## When a script fails

A script fails when it exits with a non-zero status, runs longer than its `timeout`, or can't be started. A failure
doesn't stop anything else: the manifests are still applied, and the other scripts still run. When everything is
done, `load_from_github` fails, with the list of each script and manifest that failed, and `initialize_platform`
logs that list, and carries on with its other steps.

## Security

**Reviewers must read every line of every script, and of every file it runs or reads, before merging it.** A
script runs on every Smarter platform that's deployed after the merge.

A script receives only the environment above: never the platform's own cloud or LLM provider credentials. But a
limited environment is not a sandbox. A script runs as a plain process, in the same container as
`initialize_platform`, as the same operating-system user, with the same file system and network access. And it
receives the password of the database server's administrator, because creating a database and its users is what a
`pre` script typically does: with it, a script can read or change every database on that server, the platform's own
included. So a script should:

- do one clearly described job, and touch only what it creates;
- download nothing, and run nothing that isn't in this repository;
- create users with the least privilege that they need, as Stackademy's script does;
- never print, store or send a password, or any data it reads.

## Write and test a script

1. Copy [`getting-started.sh`](getting-started.sh) to a new name, make it executable, and replace its last section
   with what your script does. Keep `set -eu`, the `--help`, and one report line per step.
2. Run it on your own computer, from the repository's root folder, with the variables that Smarter would give it.
   For Smarter's local development environment:

   ```console
   SMARTER_REPOSITORY_ROOT="$PWD" SMARTER_DATABASE_HOST=127.0.0.1 SMARTER_DATABASE_PORT=3306 \
     SMARTER_DATABASE_ADMIN_USERNAME=root MYSQL_PWD=your-local-password \
     scripts/your-script.sh
   ```

   Run it twice: the second run must succeed too.

3. List it in [`scripts.yaml`](scripts.yaml), and run `make check`, which checks it with
   [ShellCheck](https://www.shellcheck.net).
4. To try the whole load, push your branch to your fork's default branch, and load the fork into a local Smarter
   platform:

   ```console
   python manage.py load_from_github --url https://github.com/<you>/example-manifests --username <a local user> --run_scripts
   ```

   It reports each script and manifest, and what failed.

[Stackademy](https://github.com/smarter-sh/stackademy) has a real one:
[`scripts/create-course-database.sh`](https://github.com/smarter-sh/stackademy/blob/main/scripts/create-course-database.sh)
creates the course database that its SqlConnection connects to.
