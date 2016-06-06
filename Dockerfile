FROM elixir:1.2.5

WORKDIR /usr/src/app
COPY . /usr/src/app

RUN mix local.hex --force
RUN mix deps.get
RUN mix compile

CMD ["mix", "run"]
