# fig-buildbox-agent

A [Docker](http://docker.io/) and [Fig](http://fig.sh/) enabled version of the [Buildbox agent](https://github.com/buildbox/buildbox-agent) which runs each CI job in it's own set of Docker containers. Just add a `fig.yml` to each project (see [the postgres example app](https://github.com/toolmantim/fig-ci-test-app)) and you've have completely isolated testing with a custom environment for every build job.

Each project can define as many containers as it needs (e.g. Ruby, Postgres, Redis, etc) using the standard [fig.yml config syntax](http://www.fig.sh/yml.html). Before a build step is run, Fig builds and links all the required containers, and then destroys them afterwards. All you need to do is make sure your project has a fig.yml file.

The Docker containers are namespaced to each build job (rather than Docker-in-Docker style), so you get the benefit of per-job isolation but with fast build and start times thanks to Docker's cache. And you're free to run as many side-by-side buildbox agents as you wish.

*How does it work?* It uses a [customised bootstrap.sh](bootstrap.fig.sh#L59) file which calls Fig before and after the build script is run.

## Setup

### With Fig and Docker

This repository defines it's own fig.yml file and can be started inside a Docker using Fig:

```bash
$ git clone https://github.com/toolmantim/fig-buildbox-agent.git
$ cd fig-buildbox-agent
$ cp fig.sample.yml fig.yml
$ sed -i '' "s/abc123/<your agent token>/g" fig.yml
$ fig scale agent=2
Starting figbuildboxagent_agent_1...
Starting figbuildboxagent_agent_2...
$ fig logs
Attaching to figbuildboxagent_agent_2, figbuildboxagent_agent_1
agent_2 | 2014-08-30 15:34:36 [INFO ] Registering agent (name:  hostname: 8bff65bc5094 meta-data: [fig])
agent_2 | 2014-08-30 15:34:39 [INFO ] Started agent `8bff65bc5094` (pid: 1 version: 1.0-beta.1)
agent_1 | 2014-08-30 15:34:36 [INFO ] Registering agent (hostname: 5cd0389ccd95 meta-data: [fig] name: )
agent_1 | 2014-08-30 15:34:39 [INFO ] Started agent `5cd0389ccd95` (version: 1.0-beta.1 pid: 1)
agent_1 | 2014-08-30 15:35:43 [INFO ] Starting job d5feb2f5-7ee3-44eb-8999-91b58d0f4a7b
agent_2 | 2014-08-30 15:35:44 [INFO ] Starting job 916200f4-57f8-435b-831b-6def4d413b7f
agent_2 | 2014-08-30 15:35:45 [INFO ] Starting to run script: /.buildbox/bootstrap.fig.sh
agent_2 | 2014-08-30 15:35:45 [INFO ] Process is running with PID: 16
agent_1 | 2014-08-30 15:35:45 [INFO ] Starting to run script: /.buildbox/bootstrap.fig.sh
agent_1 | 2014-08-30 15:35:45 [INFO ] Process is running with PID: 16
agent_1 | 2014-08-30 15:36:14 [INFO ] Finished job d5feb2f5-7ee3-44eb-8999-91b58d0f4a7b
agent_2 | 2014-08-30 15:36:14 [INFO ] Finished job 916200f4-57f8-435b-831b-6def4d413b7f
^C
Aborting.
$ fig stop
Stopping figbuildboxagent_agent_2...
Stopping figbuildboxagent_agent_1...
```

### Outside of Docker

If you don't want to run the build agent itself using Fig and Docker following these steps (or use the [Dockerfile](Dockerfile) and [fig.yml](fig.yml) as examples):

* Install Fig and Docker.
* Ensure Docker is running.
* Install buildbox-agent as per usual.
* Copy [bootstrap.fig.sh](bootstrap.fig.sh) to the buildbox agent directory (usually `/home/buildbox/.buildbox/` if you installed it as the buildbox user).
* Start your buildbox agents with `--bootstrap-script /home/buildbox/.buildbox/bootstrap.fig.sh`

## Setting up your projects

### Adding the fig.yml

Every app must have a `fig.yml` with an `app` container. The app container is where the agent will to run your build scripts inside of (using `fig run app <build-script>`).

See the [fig-ci-test-app](https://github.com/toolmantim/fig-ci-test-app) for an example yml that creates an `app` and a `db` container:

```yml
app:
  build: .
  links:
    - db
db:
  image: postgres
```

You can also see the [Fig documentation](http://fig.sh/) for all the options available in your fig.yml, as well as example configurations for various languages and frameworks.

### Configuring your Buildbox project's build pipeline

* Set your build steps as normal. They'll be executed relative to your `app` container's working directory.
* The agent starts with the metadata `fig=true` so you can easily target fig-enabled agents in your build pipeline.

![image](https://cloud.githubusercontent.com/assets/153/4101107/b8f9bee2-30d1-11e4-97f6-4468622c080d.png)
