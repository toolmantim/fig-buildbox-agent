# fig-buildbox-agent

A [Docker](http://docker.io/) and [Fig](http://fig.sh/) enabled version of the [Buildbox agent](https://github.com/buildbox/buildbox-agent), which allows you to run each CI job in separate Docker containers. Just add a `fig.yml` to each project ([for example](https://github.com/toolmantim/fig-ci-test-app)) and define it’s Docker configuration.

Each app can spin up as many containers as it needs (e.g. Ruby, Postgres, Redis, etc) using whichever versions they need. And each job’s daemons never collide.

And because the agent uses fig itself, you can scale up your agents with a simple `fig scale agent=<number of agents>`.

*How does it work?* It uses a customised [bootstrap.sh](bootstrap.sh#59) file which calls fig before and after the build script is run.

## Agent Setup

```bash
git clone https://github.com/toolmantim/fig-buildbox-agent.git
cd fig-buildbox-agent
cp fig.sample.yml fig.yml
sed -i '' "s/abc123/<yout agent token>/g" fig.yml
fig up -d
fig logs
```

By default fig will start 1 agent instance. You can scale up using `fig scale`, for example:

```
fig scale agent=4
```

## App Setup

Every app must have a `fig.yml` which defines an `app` container. The app container is where your build scripts are executed inside of.

See [fig-ci-test-app](https://github.com/toolmantim/fig-ci-test-app) for an example and [http://fig.sh/](http://fig.sh/) for more details.

## Buildbox Project Settings

The agent starts with the metadata `fig=true`, so you can target fig-enabled agents in your Build Pipeline Settings.

Your build script paths are as normal, they'll simply execute inside your `app` fig container.
