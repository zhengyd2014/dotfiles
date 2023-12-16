#!/usr/local/bin/python3

import datetime as dt
import time
import click


@click.group()
def cli():
    pass


@cli.command()
@click.argument('timestamp')
def timestamp(timestamp: str):
    """convert timestamp to date"""
    if len(timestamp) > 10:
        timestamp = timestamp[:10]

    click.secho(dt.datetime.fromtimestamp(int(timestamp)).isoformat(), fg="green")


@cli.command()
@click.argument("datetime")
def parse(datetime: str):
    timestamp = int(time.mktime(time.strptime(datetime, "%Y-%m-%dT%H:%M:%S"))) - time.timezone
    click.secho(str(timestamp), fg="green")


if __name__ == '__main__':
    cli()

