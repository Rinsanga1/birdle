import {
  HttpApi,
  HttpApiBuilder,
  HttpApiEndpoint,
  HttpApiGroup,
  HttpApiSwagger,
} from "@effect/platform";
import { BunHttpServer, BunRuntime } from "@effect/platform-bun";
import { Effect, Layer, Schema } from "effect";
import {
  getValidGuesses,
  getWordOfTheDay,
  isValidWord,
} from "./src/game/words.js";
import { evaluateGuess } from "./src/game/logic.js";

const GuessSchema = Schema.Struct({
  guess: Schema.String.pipe(Schema.minLength(5), Schema.maxLength(5)),
});

const EvaluateSchema = Schema.Struct({
  hiddenWord: Schema.String.pipe(Schema.minLength(5), Schema.maxLength(5)),
  guess: Schema.String.pipe(Schema.minLength(5), Schema.maxLength(5)),
});

const WordsApi = HttpApiGroup.make("words").add(
  HttpApiEndpoint.get("list", "/words").addSuccess(
    Schema.Struct({ words: Schema.Array(Schema.String) })
  )
).add(
  HttpApiEndpoint.get("today", "/words/today").addSuccess(
    Schema.Struct({ word: Schema.String, date: Schema.String })
  )
);

const GameApi = HttpApiGroup.make("game").add(
  HttpApiEndpoint.post("validate", "/game/validate")
    .setPayload(GuessSchema)
    .addSuccess(Schema.Struct({ valid: Schema.Boolean }))
).add(
  HttpApiEndpoint.post("evaluate", "/game/evaluate")
    .setPayload(EvaluateSchema)
    .addSuccess(
      Schema.Struct({
        letters: Schema.Array(
          Schema.Struct({
            char: Schema.String,
            type: Schema.Union(
              Schema.Literal("none"),
              Schema.Literal("hit"),
              Schema.Literal("partial"),
              Schema.Literal("miss"),
              Schema.Literal("removed")
            ),
          })
        ),
      })
    )
);

const BirdleApi = HttpApi.make("BirdleApi").add(WordsApi).add(GameApi);

const wordsHandlers = HttpApiBuilder.group(BirdleApi, "words", (handlers) =>
  handlers
    .handle("list", () => Effect.succeed({ words: getValidGuesses() }))
    .handle("today", () => getWordOfTheDay())
);

const gameHandlers = HttpApiBuilder.group(BirdleApi, "game", (handlers) =>
  handlers
    .handle("validate", ({ payload }) =>
      Effect.succeed({ valid: isValidWord(payload.guess) })
    )
    .handle("evaluate", ({ payload }) =>
      evaluateGuess(payload.hiddenWord, payload.guess)
    )
);

const ApiLive = HttpApiBuilder.api(BirdleApi).pipe(
  Layer.provide(wordsHandlers),
  Layer.provide(gameHandlers)
);

const ServerLive = HttpApiBuilder.serve().pipe(
  Layer.provide(HttpApiBuilder.middlewareCors()),
  Layer.provide(HttpApiSwagger.layer()),
  Layer.provide(ApiLive),
  Layer.provide(BunHttpServer.layer({ port: 3000 }))
);

console.log("Starting server on http://localhost:3000");
console.log("Swagger docs at http://localhost:3000/docs");

BunRuntime.runMain(Layer.launch(ServerLive));
